perl 190_load_txtable.pl -x "C:\Projects\Vo\MOW Dataroom\Data_mapping.xls"
perl 192_load_indicatormap_table.pl -x "C:\Projects\Vo\MOW Dataroom\Data_mapping.xls"
perl 194_indicatormap2txtable.pl
perl 10_organisatie.pl
perl 20_personen.pl
perl 30_references.pl
perl 35_organisatie_ids.pl
perl 40_trefwoorden.pl
perl 50_gepubliceerd.pl
perl 60_Freqs_in_RefTable.pl
perl 70_Frequenties.pl
perl 80_load_dimensies.pl -x "C:\Projects\Vo\MOW Dataroom\Data_mapping.xls"
perl 100_indicatorfiche.pl
perl 120_handle_beleidsdocumenten.pl
perl 205_indicator2fiche.pl
perl 220_get_dim_elementen.pl
perl 500_indicator_report.pl
rem perl 600_netwerklink_Albertkanaal.pl
