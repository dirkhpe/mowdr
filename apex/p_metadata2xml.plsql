create or replace procedure p_metadata2xml (p_indic_id indicatorfiche.indicatorfiche_id%TYPE)
IS
    -- This procedure allows to extract metadata information for a specific indicatorfiche into xml format.
    proc_name logtbl.evt_proc%TYPE := 'p_metadata2xml';
    err_msg varchar2(255);
    
    f utl_file.file_type;
    v_filename varchar2(255);
    
	cursor fiche_cursor is
	SELECT indicator_naam,
		definitie,
		berekeningswijze,
		doel_meting,
		meettechniek,
		f_referentielabel(type_indicator) w_type_indicator,
		f_referentielabel(meeteenheid) w_meeteenheid,
		meetfrequentie,
		tijdvenster,
		f_cijfers_laatst_bijgewerkt(indicator_id) cijfers_bijgewerkt,
		f_jn_aantal(aantal_percentage) w_aantal_percentage
	FROM indicatorfiche
	WHERE indicatorfiche_id = p_indic_id;

	type fiche_record is record (
        r_indicator_naam indicatorfiche.indicator_naam%TYPE,
        r_definitie indicatorfiche.definitie%TYPE,
        r_berekeningswijze indicatorfiche.berekeningswijze%TYPE,
        r_doel_meting indicatorfiche.doel_meting%TYPE,
        r_meettechniek indicatorfiche.meettechniek%TYPE,
        r_type_indicator referentie.waarde%TYPE,
        r_meeteenheid referentie.waarde%TYPE,
        r_meetfrequentie indicatorfiche.meetfrequentie%TYPE,
        r_tijdvenster indicatorfiche.tijdvenster%TYPE,
		r_cijfers_bijgewerkt varchar2(50),
        r_aantal_percentage varchar2(255));
    fiche fiche_record;

    procedure ip_dimensies (v_indicatorfiche_id IN indicatorfiche.indicatorfiche_id%TYPE) 
    is
        cursor dimensie_cursor is
        select waarde
        from dimensie_fiche f, dimensie d
        where fiche_id = v_indicatorfiche_id
        and f.dimensie_id = d.dimensie_id;
        dim_waarde dimensie.waarde%TYPE;
		v_dim_str varchar2(4000);
		v_length number;

    begin
        
        open dimensie_cursor;
        loop
            fetch dimensie_cursor into dim_waarde;
            exit when dimensie_cursor%NOTFOUND;
			v_dim_str := v_dim_str || dim_waarde || "; "
        end loop;
		v_length := LENGTH(v_dim_str);
		IF v_length > 2 THEN
			v_dim_str := SUBSTR(v_dim_str, 1, v_length-2);
			utl_file.put_line(f,'<![CDATA[' || v_dim_str || ']]>');
		END IF
    EXCEPTION
        WHEN OTHERS THEN
            err_msg:= SUBSTR(SQLERRM, 1, 100);
            p_log(proc_name || ' in ip_dimensies', 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace); 
    end;

BEGIN
    p_log(proc_name, 'I', 'Start Application for ID: ' || p_indic_id);

    v_filename := 'metadata_' || lpad(p_indic_id, 3, '0') || '.xml';
    f := utl_file.fopen('DATAROOM_OUT', v_filename, 'w');

    utl_file.put_line(f, '<?xml version="1.0"?>');
    utl_file.put_line(f, '<metadata>');
    
	OPEN fiche_cursor;
	LOOP
		FETCH fiche_cursor INTO fiche;
		EXIT WHEN fiche_cursor%NOTFOUND;
		utl_file.put_line(f,'<Title><![CDATA[' || fiche.r_indicator_naam || ']]></Title>');
        utl_file.put_line(f,'<Definitie><![CDATA[' || fiche.r_definitie || ']]></Definitie>');
        utl_file.put_line(f,'<Berekeningswijze><![CDATA[' || fiche.r_berekeningswijze || ']]></Berekeningswijze>');
        utl_file.put_line(f,'<DoelMeting><![CDATA[' || fiche.r_doel_meting || ']]></DoelMeting>');
        utl_file.put_line(f,'<Meettechniek><![CDATA[' || fiche.r_meettechniek || ']]></Meettechniek>');
        utl_file.put_line(f,'<TypeIndicator><![CDATA[' || fiche.r_type_indicator || ']]></TypeIndicator>');
        utl_file.put_line(f,'<Meeteenheid><![CDATA[' || fiche.r_meeteenheid || ']]></Meeteenheid>');
        utl_file.put_line(f,'<Meetfrequentie><![CDATA[' || fiche.r_meetfrequentie || ']]></Meetfrequentie>');
        utl_file.put_line(f,'<Dimensies>');
        ip_dimensies(fiche.r_indicatorfiche_id);
        utl_file.put_line(f,'</Dimensies>');
        utl_file.put_line(f,'<Tijdsvenster><![CDATA[' || fiche.r_tijdvenster || ']]></Tijdsvenster>');
        utl_file.put_line(f,'<CijfersBijgewerkt><![CDATA[' || fiche.r_cijfers_bijgewerkt || ']]></CijfersBijgewerkt>');
        utl_file.put_line(f,'<AantalPercentage><![CDATA[' || fiche.r_aantal_percentage || ']]></AantalPercentage>');
	END LOOP;	
	utl_file.put_line(f, '</metadata>');
    utl_file.fclose(f);
    p_log(proc_name, 'I', 'End Application');

EXCEPTION
    WHEN OTHERS THEN
        err_msg:= SUBSTR(SQLERRM, 1, 100);
        p_log(proc_name, 'E', 'Onverwachte fout: ' || err_msg || ' backtrack: ' || DBMS_UTILITY.format_error_backtrace);
END;
