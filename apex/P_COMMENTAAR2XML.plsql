create or replace PROCEDURE  "P_COMMENTAAR2XML" (p_indicatorfiche_id IN indicatorfiche.indicatorfiche_id%TYPE)
IS
    -- Add test not to create a file if there are no comments.
    proc_name logtbl.evt_proc%TYPE := 'p_commentaar2xml';
    cursor comm_cursor is
    select periode,
        beschrijving
    from commentaar
    where indicatorfiche_id = p_indicatorfiche_id
    order by dagnr;
    type comm_record is record (
        r_periode commentaar.periode%TYPE,
        r_beschrijving commentaar.beschrijving%TYPE);
        
    comm comm_record;
    f utl_file.file_type;
    filename varchar2(255);
    err_msg varchar2(255);
BEGIN
    p_log(proc_name, 'I', 'Start Application for ID: ' || p_indicatorfiche_id);
    
    filename := 'commentaar_' || lpad(p_indicatorfiche_id,2,'0') || '.xml';
    f := utl_file.fopen('DATAROOM_OUT', filename, 'w');
    
    utl_file.put_line(f, '<?xml version="1.0"?>');
    utl_file.put_line(f, '<commentaar>');
    
    OPEN comm_cursor;
    LOOP
        FETCH comm_cursor INTO comm;
        EXIT WHEN comm_cursor%NOTFOUND;
    
        utl_file.put_line(f,'<commentaar_record>');
        utl_file.put_line(f,'<periode>' || comm.r_periode || '</periode>');
        utl_file.put_line(f,'<beschrijving><![CDATA[' || comm.r_beschrijving || ']]></beschrijving>');
        utl_file.put_line(f,'</commentaar_record>');
         
    END LOOP;
    utl_file.put_line(f, '</commentaar>');
    utl_file.fclose(f);
EXCEPTION
    
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);        
END;
