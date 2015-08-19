create or replace procedure p_cijfers2xml (p_indic_id indicatorfiche.indicatorfiche_id%TYPE)
IS
    -- This procedure allows to extract cijferrecords for a specific indicatorfiche into xml format.
    proc_name logtbl.evt_proc%TYPE := 'p_cijfers2xml';
    err_msg varchar2(255);
    
    f utl_file.file_type;
    v_filename varchar2(255);
    v_meetfrequentie indicatorfiche.meetfrequentie%TYPE;
    v_meeteenheid referentie.waarde%TYPE;
    v_ap varchar2(10);
    v_title_row varchar2(1024);
    type t_res is table of varchar2(1024);
    v_res t_res;
    v_cols t_res;
    v_fields string_fnc.t_array;
    ind number := 1;
    v_query varchar2(1024);
    
    PROCEDURE p_freqrow(p_meetfrequentie IN indicatorfiche.meetfrequentie%TYPE) 
    IS
    -- This procedure will add frequency attributes to Column.
    BEGIN
        IF (lower(p_meetfrequentie) = 'jaar') THEN
            v_cols.extend;
            v_cols(ind) := 'jaar';
            ind := ind + 1;
        ELSIF (lower(p_meetfrequentie) = 'maand') THEN
            v_cols.extend;
            v_cols(ind) := 'jaar';
            v_cols.extend;
            v_cols(ind+1) := 'maand';
            ind := ind + 2;
        ELSIF (lower(p_meetfrequentie) = 'kwartaal') THEN
            v_cols.extend;
            v_cols(ind) := 'jaar';
            v_cols.extend;
            v_cols(ind+1) := 'kwartaal';
            ind := ind + 2;
        ELSIF (lower(p_meetfrequentie) = 'schooljaar') THEN
            v_cols.extend;
            v_cols(ind) := 'schooljaar';
            ind := ind + 1;
        ELSE
            p_log(proc_name || '_p_freqrow', 'E', 'Onbekende meetfrequentie: ' || p_meetfrequentie);
        END IF;
    EXCEPTION
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name || '_p_freqrow', 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
    END;
 
    PROCEDURE p_dimrow
        IS
        CURSOR dimensie_cursor IS
            SELECT kolomnaam
                FROM dimensie d, dimensie_fiche f
                WHERE f.fiche_id = p_indic_id
                AND f.dimensie_id = d.dimensie_id
                ORDER BY kolomnaam;
        v_waarde dimensie.waarde%TYPE;
    BEGIN
        OPEN dimensie_cursor;
        LOOP
            FETCH dimensie_cursor INTO v_waarde;
            EXIT WHEN dimensie_cursor%NOTFOUND;
            v_cols.extend;
            v_cols(ind) := v_waarde;
            ind := ind + 1;
        END LOOP;
    EXCEPTION
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name || '_p_dimrow', 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
    END;
        
        
BEGIN
    p_log(proc_name, 'I', 'Start Application for ID: ' || p_indic_id);
    SELECT f_referentielabel(meeteenheid), meetfrequentie, f_jn_aantal(aantal_percentage) 
        INTO v_meeteenheid, v_meetfrequentie, v_ap
        FROM indicatorfiche
        WHERE indicatorfiche_id = p_indic_id;
    v_filename := 'cijfers_' || lpad(p_indic_id, 2, '0') || '.xml';
    f := utl_file.fopen('DATAROOM_OUT', v_filename, 'w');
    utl_file.put_line(f, '<?xml version="1.0"?>');
    utl_file.put_line(f, '<cijferrecords>');
    v_cols := t_res(NULL);
    v_cols.extend;
    v_cols(ind) := v_meeteenheid;
    ind := ind + 1;
    p_freqrow(v_meetfrequentie);
       p_dimrow;
    -- Read all records for this indicator
    -- and extract information for xml file.
    v_query := 'SELECT f_rep_period(indicator_report_id) || f_rep_dimensions(indicator_report_id)
                FROM indicator_report
                WHERE indicatorfiche_id = ' || p_indic_id || '
                ORDER BY dagnr, indicator_report_id';
    execute immediate v_query bulk collect into v_res;
    if v_res.count > 0 THEN
        for i in v_res.first..v_res.last loop
            -- p_log(proc_name, 'T', v_res(i)); 
            v_fields := string_fnc.split(v_res(i) || ';', ';');
            -- utl_file.put_line(f,v_res(i));
            utl_file.put_line(f,'<record>');
            for j in 1..ind-1 loop
                utl_file.put_line(f,'<' || v_cols(j) || '>');
                utl_file.put_line(f,v_fields(j+1));    -- shifted by one?
                utl_file.put_line(f,'</' || v_cols(j) || '>');
            end loop;
            utl_file.put_line(f,'</record>');
        end loop;
    END IF;
    utl_file.put_line(f, '</cijferrecords>');
    utl_file.fclose(f);
    p_log(proc_name, 'I', 'End Application');
EXCEPTION
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
END;
