# ==========================================================================
# $Source$
# $Author$ [pauwel]
# $Date$
# CDate: Thu Jun 14 17:19:32 2012
# $Revision$
#
# ==========================================================================
#
# ident "$Id$"
#
# ==========================================================================

=pod

Mysql database access layer.

=cut


package DbUtil;

use strict;
use warnings;
use Carp;
use Log::Log4perl qw(:easy get_logger);
use DBI;
use IniUtil qw(get_ini);

use Data::Dumper;

BEGIN {
  use Exporter ();
  our ($VERSION, @ISA, @EXPORT, @EXPORT_OK);

  $VERSION = '1.0';

  @ISA         = qw(Exporter);

  @EXPORT    = qw();

  @EXPORT_OK = qw(db_connect
                  do_stmt
                  do_execute
                  do_prepare
                  singleton_select
				  singleton_select_href
                  sth_singleton_select
                  do_select
				  do_select_arrays

                  mysql_datatype_length

                  create_record
                  rcreate_record
                  rupdate_record

                  flush_table
                  get_recordid get_recordid_from_source
                  get_field
                  clear_fields
                );


#do_sth_fetchall
#prepare_record_sth
#create_record_sth
#get_field_sth
#get_field_sth_data

}

# ==========================================================================

=item db_connect(alu_cmdb|cim)

connect to source or target database

=cut

sub db_connect {
  my $db = shift;
  my ($port, $server, $username, $password);

  my $cfg = get_ini();
  my $log = get_logger();

  if (defined $cfg) {
    if ($cfg->SectionExists($db)) {
      if ($cfg->val($db, 'port')) { $port = $cfg->val($db, 'port'); }
      if ($cfg->val($db, 'server')) { $server = $cfg->val($db, 'server'); }
      if ($cfg->val($db, 'username')) { $username = $cfg->val($db, 'username'); }
      if ($cfg->val($db, 'password')) { $password = $cfg->val($db, 'password'); }
    }
  }

  $log->trace("Trying database connection to ${db} with ${username}/${password}\@${server}:${port}");
  # Make database connection for target database
  my $dbh = DBI->connect("DBI:mysql:database=$db;host=$server;port=$port", $username, $password,
                         { mysql_enable_utf8 => 1,
						   mysql_server_prepare => 1,
                          'PrintError' => 1,   # Set to 1 for debug info
                          'RaiseError' => 0}); # Do not die on error

  # mysql_enable_utf8=1

  if (defined $dbh) {
	$log->debug("Database connection to $db on host $server:$port configured");
  } else {
    $log->error("Could not open database `$db' on host `$server:$port'");
    return;
  }

  do_stmt($dbh, "SET SESSION sql_mode='STRICT_ALL_TABLES'") or do { $log->warn("Can't set database in strict mode !"); };

  do_stmt($dbh, "SET NAMES 'utf8'") or do { $log->warn("Can't set database in utf8 mode !"); };

  return $dbh;
}


=pod

=head2 do_stmt

Execute SQL statement without the need for getting additional information back, except error logging. This statement can be used for create table, truncate table, ...

Usage: do_stmt(dbh, statement [, attributes, bind_values])

Return value is result of the statement (and depending on the statement) or undefined in case of error.

=cut

sub do_stmt {
  LOGCONFESS("usage: do_stmt(dbh, statement, [ attr, bind_values ])") unless @_ >= 2;

  my $dbh = shift;
  my $statement = shift;
  my $log = get_logger();

#  my $rv = $dbh->do($statement, @_);
  my $sth = $dbh->prepare($statement);
  my $rv  = $sth->execute(@_);

  unless (defined $rv) {
    $log->error("Could not perform statement `$statement'. Error: " . $dbh->errstr);
    return;
  }

  return $rv;
}


=pod

=head2 do_execute


This procedure will prepare and execute a statement. The statement handle is returned, or undefined in case of an issue.

In do_execute the statement handle is returned, to allow further processing of the data.

=cut

sub do_execute {
  LOGCONFESS("usage: do_execute(dbh, statement, parms, ...)") unless @_ >= 2;
  my $log = get_logger();
  my ($dbh, $statement, @parms) = @_;

  my $sth = $dbh->prepare($statement);

  unless ($sth) {
    $log->error("Could not prepare statement `$statement'. Error: " . $dbh->errstr);
    return;
  }

  unless ( $sth->execute( @parms ) ) {
    $log->error("Could not execute statement `$statement' . Error: " . $sth->errstr);
    $sth->finish();
    return;
  }

  return $sth;
}

# ==========================================================================

sub do_prepare {
  LOGCONFESS("usage: do_prepare(dbh, statement)") unless @_ == 2;

  my ($dbh, $statement) = @_;

  my $sth = $dbh->prepare($statement);

  unless ($sth) {
    ERROR("Could not prepare statement `$statement'. Error: " . $dbh->errstr);
    return;
  }

  return $sth;
}

# ==========================================================================

sub singleton_select {
  LOGCONFESS("usage: singleton_select(dbh, query, parms, ...)") unless @_ >= 2;
  my $log = get_logger();

  my ($dbh, $qry, @parms) = @_;

  my $sth = $dbh->prepare($qry);

  unless ($sth) {
    $log->error("Could not prepare query `$qry'. Error: " . $dbh->errstr);
    return;
  }

  unless ( $sth->execute( @parms ) ) {
    my $query = $sth->{Statement};
    $log->error("Could not execute query `$query' . Error: " . $sth->errstr);
    $sth->finish();
    return;
  }

  my $ary_ref  = $sth->fetchall_arrayref({});

  if ($sth->err) {
    my $query = $sth->{Statement};
    $log->error("Could not fetchall_arrayref query `$query'. Error: " . $sth->errstr);
    $sth->finish();
    return;
  }

  if (@$ary_ref > 1) {
    my $query = $sth->{Statement};
    $log->warn("singleton_select `$query' returns too many rows, one expected!");
    $sth->finish();
  }

  if (@$ary_ref < 1) {
    my $query = $sth->{Statement};
    $log->info("singleton_select `$query' returns no rows !");
    $sth->finish();
    return [];
  }

  return [ $ary_ref->[0] ];
}

# ==========================================================================

sub singleton_select_href {
  LOGCONFESS("usage: singleton_select(dbh, query, parms, ...)") unless @_ >= 2;

  my ($dbh, $qry, @parms) = @_;
  my $log = get_logger();

  my $sth = $dbh->prepare($qry);

  unless ($sth) {
    $log->error("Could not prepare query `$qry'. Error: " . $dbh->errstr);
    return;
  }

  unless ( $sth->execute( @parms ) ) {
    my $query = $sth->{Statement};
    $log->error("Could not execute query `$query' . Error: " . $sth->errstr);
    $sth->finish();
    return;
  }

  my $href  = $sth->fetchall_hashref({});

  if ($sth->err) {
    my $query = $sth->{Statement};
    $log->error("Could not fetchrow_hashref query `$query'. Error: " . $sth->errstr);
    $sth->finish();
    return;
  }

  my $nr_rec = @$href;
  unless ($nr_rec == 1) {
    my $query = $sth->{Statement};
    $log->error("singleton_select_href `$query' returns $nr_rec rows, one row expected!");
    $sth->finish();
    return;
  }
  #Ends the open sql statement
  $sth->finish();
  
  return $href;
}

# ==========================================================================

sub sth_singleton_select {
  LOGCONFESS("usage: sth_singleton_select(sth, parms, ...)") unless @_ >= 1;

  my ($sth, @parms) = @_;

  unless ( $sth->execute( @parms ) ) {
    my $query = $sth->{Statement};
    ERROR("Could not execute query `$query' . Error: " . $sth->errstr);
    return;
  }

  my $ary_ref  = $sth->fetchall_arrayref();

  if ($sth->err) {
    my $query = $sth->{Statement};
    ERROR("Could not fetchall_arrayref query `$query'. Error: " . $sth->errstr);
    $sth->finish();
    return;
  }

  if (@$ary_ref > 1) {
    my $query = $sth->{Statement};
    WARN("sth_singleton_select `$query' returns too many rows !");
    $sth->finish();
  }

  if (@$ary_ref < 1) {
    my $query = $sth->{Statement};
    INFO("sth_singleton_select `$query' returns no rows !");
    $sth->finish();
    return [];
  }

  return [ $ary_ref->[0] ];
}

=pod

=head2 do_select procedure

Execute the SQL query and return an array reference to the resultset in hashes (fetchall_arrayref({})).

Note that if the resultset needs to be an arrayref of arrays, then the procedure do_select_arrays needs to be called.

Usage: do_select(dbh, query [, parms, ...])

=cut

sub do_select {
  LOGCONFESS("usage: do_select(dbh, query, parms, ...)") unless @_ >= 2;
  my $log = get_logger();

  my ($dbh, $query, @parms) = @_;

  my $sth = $dbh->prepare($query);

  unless ($sth) {
    $log->error("Could not prepare query `$query'. Error: " . $dbh->errstr);
    return;
  }

  unless ( $sth->execute( @parms ) ) {
    $log->error("Could not execute query `$query' . Error: " . $sth->errstr);
    $sth->finish();
    return;
  }

  my $ary_ref  = $sth->fetchall_arrayref({});

  if ($sth->err) {
    $log->error("Could not fetchall_arrayref for query `$query'. Error: " . $sth->errstr);
    $sth->finish();
    return;
  }

  if (@$ary_ref < 1) {
    $log->trace("query `$query' returns no rows !");
    $sth->finish();
    return [];
  }

  return $ary_ref;
}

=pod

=head2 do_select_arrays procedure

Execute the SQL query and return an array reference to the resultset in arrays (fetchall_arrayref()).

Note that if the resultset needs to be an arrayref of hashes, then the procedure do_select needs to be called.

Usage: do_select_arrays(dbh, query [, parms, ...])

=cut

sub do_select_arrays {
  LOGCONFESS("usage: do_select_arrays(dbh, query, parms, ...)") unless @_ >= 2;
  my $log = get_logger();

  my ($dbh, $query, @parms) = @_;

  my $sth = $dbh->prepare($query);

  unless ($sth) {
    $log->error("Could not prepare query `$query'. Error: " . $dbh->errstr);
    return;
  }

  unless ( $sth->execute( @parms ) ) {
    $log->error("Could not execute query `$query' . Error: " . $sth->errstr);
    $sth->finish();
    return;
  }

  my $ary_ref  = $sth->fetchall_arrayref();

  if ($sth->err) {
    $log->error("Could not fetchall_arrayref for query `$query'. Error: " . $sth->errstr);
    $sth->finish();
    return;
  }

  if (@$ary_ref < 1) {
    $log->trace("query `$query' returns no rows !");
    $sth->finish();
    return [];
  }

  return $ary_ref;
}

# ==========================================================================
# deze gebruik ik voorlopig niet
# ==========================================================================


sub do_sth_fetchall {
  LOGCONFESS("usage: do_sth_fetchall(sth, parms, ...)") unless @_ >= 1;

  my ($sth, @parms) = @_;

  unless ( $sth->execute( @parms ) ) {
    my $query = $sth->{Statement};
    ERROR("Could not execute query `$query' . Error: " . $sth->errstr);
    return;
  }

  my $ary_ref  = $sth->fetchall_arrayref();

  if ($sth->err) {
    my $query = $sth->{Statement};
    ERROR("Could not fetchall_arrayref query `$query'. Error: " . $sth->errstr);
    return;
  }

  if (@$ary_ref < 1) {
    my $query = $sth->{Statement};
    INFO("query `$query' returns no rows !");
    return [];
  }

  return $ary_ref;
}


# ==========================================================================

=item mysql_datatype_length

give the max length for a data type (to check that a string of a certain size can be loaded)

=cut

sub mysql_datatype_length {
  my $type = shift;

  my $l = 1;

  if    ($type =~ m/^varchar\((\d*)\)$/i) { $l = $1; }
  elsif ($type =~ m/^int\((\d*)\)$/i)     { $l = $1; }
  elsif ($type =~ m/^tinytext$/i)         { $l = 256; }
  elsif ($type =~ m/^text$/i)             { $l = 64000; }
  elsif ($type =~ m/^mediumtext$/i)       { $l = 16000000; }
  elsif ($type =~ m/^longtext$/i)         { $l = 4000000000; }
  elsif ($type =~ m/^double$/i)           { $l = 0; } # niet checken, weet niet goed hoe
  elsif ($type =~ m/^datetime$/i)         { $l = 0; } # niet checken, ik check dit als ik de data formateer voor insert

  return $l;
}

# ==========================================================================
# ==========================================================================
# Dit was een proging om de create_record subroutine van Dirk te versnellen, door een statement
# eerst te 'preparen' en daarna meerdere keren te 'executen' met verschillende parameters.
# Bij een Oracle database werkt dat altijd prima, maar bij mysql maakt dat blijkbaar geen lap
# verschil.
# Op internet gevonden dat dit inderdaad zo is. Enige voordeel van bind variabelen versus variabelen
# in een string is dat je de inhoud van de variabelen niet moet quoten (en dat moet je wel doen als
# je ze in een statement opneemt). Vraag mij trouwens af of dat invloed heeft op character sets.
#
# Om enig nut te hebben van de prepared statements moet je trouwens 'mysql_server_prepare=1'
# meegeven in de connect string.
# ==========================================================================

=pod

=head2 prepare_record_sth(database_handle, tablename, array of fieldnames)

This procedure will create a statement handle to insert records in the table. Fieldnames are in the array fieldnames.

Return value is the statement handle.

=cut

sub prepare_record_sth ($$$) {
  my ($dbh, $table) = @_;
  my (@fields) = @{$_[2]};

  my $fieldstr = join (', ', map { "`$_`" } @fields);
  my $valstr =  join (', ', map { '?' } @fields);
  my $query = "INSERT INTO $table ($fieldstr) VALUES ($valstr)";
  my $sth = $dbh->prepare($query);

  unless ($sth) {
    WARN($dbh->errstr);
    return;
  }

  return $sth;
}


# ==========================================================================

=pod

=head2 create_record_sth(statement_handle, array of fieldvalues)

This procedure will create a record in the table. Field values are in the array of field values.

Return value is the ID of the record that has been inserted - or blank if no record could be inserted.

=cut


sub create_record_sth ($$) {
  my ($sth) = @_;
  my (@values) = @{$_[1]};
  # quote values according to db specifications
  #my $dbh = $sth->{Database};
  #@values = map { $dbh->quote($_) } @values;
  my $rv = $sth->execute(@values);
  if (not defined $rv) {
    ERROR("Could not execute query. Error: ". $sth->errstr);
  }
  my $id = $sth->{'mysql_insertid'} || "";
  return $id;
}

# ==========================================================================

sub get_field_sth($$$$) {
  my ($dbh, $table, $qfield) = @_;
  my (@fields) = @{$_[3]};

  # Create WHERE String
  my ($wherestring);
  foreach my $field (@fields) {
    $wherestring .= "`$field` = ? AND ";
  }
  # Remove last " AND " from the wherestring
  $wherestring = substr($wherestring, 0, -5);

  my $query = "SELECT `$qfield` as qvalue
				 FROM $table
				 WHERE $wherestring";
  my $sth = $dbh->prepare($query);

  return $sth;
}


sub get_field_sth_data($$) {
  my ($sth) = @_;
  my (@values) = @{$_[1]};

  # quote values according to db specifications
  #my @values_w = map { $sth->{Database}->quote($_) } @values;

  my $rv = $sth->execute(@values);
  if (not defined $rv) {
    ERROR("Could not execute query. Error: ".$sth->errstr);
  }

  my ($qvalue);
  if (my $ref = $sth->fetchrow_hashref) {
    $qvalue = $ref->{qvalue} || "";
  } else {
    # Record doesn't exist already, return empty string
    $qvalue = "";
  }
  return $qvalue;
}

# ==========================================================================

=pod

=head2 create_record(database_handle, tablename, array of fieldnames, array of fieldvalues)

This procedure will create a record in the table. Fieldnames are in the array fieldnames, field values are in the array of field values.

Return value is the ID of the record that has been inserted - or blank if no record could be inserted.

=cut

sub create_record ($$$$) {
  my ($dbh, $table, $fields, $values) = @_;
  my $log = get_logger();

  if (@$fields != @$values) {
    $log->error("Mismatch between the number of columns and the number of values");
    return;
  }

  my $statement = "INSERT INTO $table ( " . join (', ', map { "`$_`" } @$fields) . ' ) VALUES ( ' . join (', ', map { '?' } @$values) . ')';

  my $sth = do_execute($dbh, $statement, @$values) or return;

  my $id = $dbh->{'mysql_insertid'} || '';

  $sth->finish();

  return $id;
}


# ==========================================================================

=pod

=head2 rcreate_record(database_handle, tablename, record)

This procedure will create a record in the table. The record is passed in a hash ref.

Return value is the ID of the record that has been inserted - or blank if no record could be inserted.

=cut

sub rcreate_record ($$$) {
  my ($dbh, $table, $record) = @_;

  # do a prepare/execute anyway and use bind variables. This way I don't have to quote my data.

  my (@fields) = keys %$record;

  my $statement = "INSERT INTO $table (" . join (", ", map { "`$_`" } @fields) . ") VALUES (" . join (", ", map { "?" } @fields) . ")";

  my $sth = do_prepare($dbh, $statement) or return;

  unless ( $sth->execute( values %$record ) ) {
    ERROR("Could not execute statement `$statement' . Error: " . $sth->errstr);
    $sth->finish();
    return;
  }

  my $id = $dbh->{'mysql_insertid'} || '';
  return $id;
}

# ==========================================================================

=pod

=head2 rupdate_record(database_handle, tablename, key, record)

This procedure is used to update the record with key(s) in the first hash ref.
Data is in the second hash ref.

=cut

sub rupdate_record($$$$) {
  my ($dbh, $table, $key, $record) = @_;

  # Create UPDATE statement
  my $statement = "UPDATE $table SET " . join (", ", map { "`$_` = ?" } (keys %$record) ) . " WHERE (" . join (" AND ", map { "`$_` = ?" } (keys %$key) ) . ")";

  #do_stmt($dbh, "SET SESSION sql_mode=''") or do { WARN("Can't set database in strict mode !"); };

  my $sth = do_prepare($dbh, $statement) or return;

  unless ( $sth->execute( values %$record, values %$key ) ) {
    ERROR("Could not execute statement `$statement' . Error: " . $sth->errstr);
    $sth->finish();
    return;
  }

  #do_stmt($dbh, "SET SESSION sql_mode='STRICT_ALL_TABLES'") or do { WARN("Can't set database in strict mode !"); };

  return 1;
}


# ==========================================================================

=pod

=head2 Flush Table

This script will get a table, create a new temp table without the table index, empty the original table and restore only the unique records in the original table.

The table id column will contain different values

=cut

sub flush_table($$) {
  my ($dbh, $table) = @_;

  # First remove the id column from the table
  my $id = $table . "_id";
  do_stmt($dbh, "ALTER TABLE $table DROP $id") or return;

  # Then create the temp table with DISTINCT values only
  my $temp_table = "TEMP_" . $table;
  do_stmt($dbh, "CREATE TEMPORARY TABLE $temp_table SELECT DISTINCT * FROM $table") or return;

  # Empty the original table
  do_stmt($dbh, "TRUNCATE TABLE $table") or return;

  # Move original items back into table
  do_stmt($dbh, "INSERT INTO $table SELECT * FROM $temp_table") or return;

  # And add the id column again to the table
  do_stmt($dbh, "ALTER TABLE `$table` ADD `$id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST") or return;

  return 1;
}

# ==========================================================================

=pod

=head2 Get Record ID(database_handle, tablename, array of fieldnames, array of fieldvalues)

This procedure will get the record id for the fields in array. If the record doesn't exist, it will return an empty string.

This is used for example to extract people details from the person table, or to get computersystem ID.

If the ID value should never be NULL.

=cut

sub get_recordid($$$$) {
  my ($dbh, $table) = @_;
  my (@fields) = @{$_[2]};
  my (@values) = @{$_[3]};

  # quote values according to db specifications
  my @values_w = map { $dbh->quote($_) } @values;

  my $rec_id = $table . "_id";

  my $statement = "SELECT $rec_id AS id FROM $table WHERE " . join(' AND ', map { "`$fields[$_]` = $values_w[$_]" } (0 .. $#fields));
  my $sth = do_execute($dbh, $statement) or return;

  my $id;

  if (my $ref = $sth->fetchrow_hashref) {
    $id = $ref->{id};
    if (not(defined($id))) {
      ERROR("Unexpected NULL value found in $table, field $rec_id");
    }

    # check or we have duplicate rows in the select (only expect 1 !)
    my $href2 = $sth->fetchrow_hashref();
    if ($href2) {
      my $query = $sth->{Statement};
      ERROR("get_recordid: `$query' returns more than the expected 1 row !");
    }
  } else {
    # Record doesn't exist already, return empty string
    $id = "";
  }

  return $id;
}

# ==========================================================================

=pod

=head2 Get Record ID From Source(database_handle, tablename, source, source system element id)

This procedure will get the record id for the source / source_system_element_id pair. If the record doesn't exist, it will return an empty string.

A source is stored with a timestamp attached, therefore an exact match is difficult to achieve.

This is used to get an ID from a table that has information from different sources, such as the application table. In this case a source system element id is not always unique.

If the ID value should never be NULL.

=cut

sub get_recordid_from_source($$$$) {
  my ($dbh, $table, $source, $source_system_element_id) = @_;

  if ((not defined $source) || (length($source) == 0)) {
    ERROR("get_recordid_from_source Table $table Source not defined");
    return;
  }
  elsif ((not defined $source_system_element_id) || (length($source_system_element_id) == 0)) {
    ERROR("get_recordid_from_source Table $table Source $source source_system_element_id not defined");
    return;
  }

  my $rec_id = $table . "_id";

  my $sth = do_execute($dbh, "
SELECT $rec_id AS id
  FROM $table
  WHERE source_system like '$source%'
    AND source_system_element_id = '$source_system_element_id'") or return;

  my $id;

  if (my $ref = $sth->fetchrow_hashref) {
    $id = $ref->{id};
    if (not(defined($id))) {
      ERROR("Unexpected NULL value found in $table, field $rec_id");
      $id = "";
    }
  } else {
    # Record doesn't exist already, return empty string
    $id = "";
  }

  return $id;
}

# ==========================================================================

=pod

=head2 Get Field(database_handle, tablename, field, array of fieldnames, array of fieldvalues)

This procedure will get the field value for the fields in array. If the record doesn't exist, it will return an empty string.

This is used for example to extract admin_id record, to add application type group.

=cut

sub get_field($$$$$) {
  my ($dbh, $table, $qfield) = @_;
  my (@fields) = @{$_[3]};
  my (@values) = @{$_[4]};
  # quote values according to db specifications
  my @values_w = map { $dbh->quote($_) } @values;
  # Create WHERE String
  my $wherestring = join(' AND ', map { "`$fields[$_]` = $values_w[$_]" } (0 .. $#fields));

  my $query = "SELECT `$qfield` as qvalue
                                 FROM $table
                                 WHERE $wherestring";
  my $sth = $dbh->prepare($query);
  my $rv = $sth->execute();

  if (not defined $rv) {
    ERROR("Could not execute query $query, Error: ".$sth->errstr);
    return;
  }

  my $qvalue;
  if (my $ref = $sth->fetchrow_hashref) {
    $qvalue = $ref->{qvalue} || "";
  } else {
    # Record doesn't exist already, return empty string
    $qvalue = "";
  }

  return $qvalue;
}

# ==========================================================================

=pod

=head2 Clear Fields (database_handle, tablename, array of fields)

This procedures will insert NULL values in specific field values. This is required to re-run scripts that will work on a subset of a component.

=cut

sub clear_fields($$$) {
  my ($dbh, $table, $fields) = @_;

  return do_stmt($dbh, "UPDATE `$table` SET " . join(', ', map {  "$_ = NULL" } @$fields));
}


# ==========================================================================

1;
