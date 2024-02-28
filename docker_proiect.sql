select * from user_tables;
select * from Angajati;
select * from Locatii;
select * from Magazine;
select * from Clienti;
select * from Comenzi;
select * from Produse;
select * from produs_magazin;
select * from produs_comanda;

@sterg_tabele.sql;
@insert_values.sql;
@create_sequence.sql;
@create_tables.sql;
@drop_sequence.sql;

-- EX12
create table info_actiuni
    (utilizator varchar2(30), 
    nume_bd varchar2(50), 
    eveniment varchar2(20),
    nume_obiect varchar2(30),
    ora timestamp
    );
    
create or replace trigger ex12_trigger
    after create or drop or alter on schema 
begin 
    insert into info_actiuni
    values (sys.login_user, sys.database_name, sys.sysevent, sys.dictionary_obj_name, current_timestamp); 
end; 
/

create table exemplu (
    id number,
    name varchar2(50)
);
drop table exemplu;

SELECT * FROM info_actiuni;
DROP TRIGGER ex12_trigger;
drop table audit_mra;

-- EX11
create or replace trigger ex11_trigger
    before update of pret on produse
    for each row
begin
    if (:new.pret > :old.pret) and (to_char(sysdate, 'D') = 1) -- marti = 3
        then raise_application_error(-20005, 'Pretul nu poate fi marit in zilele'
            || ' de duminica');
    end if;
end;
/

update produse
set pret = pret + 10
where id_produs = 6005;

-- EX10
create or replace trigger ex10_trigger
    before insert on angajati
begin
    if (to_char(sysdate, 'D') = 7)
        or (to_char(sysdate, 'D') = 1) -- marti = 3
        then raise_application_error(-20005, 'Nu se pot adauga angajati in week-end');
    end if;
end;
/

insert into Angajati (ID_Angajat, ID_Magazin, Nume, Prenume, CNP, Data_Angajare, Salariu) 
values (Angajat_id.nextval, 2007, 'Nedelcu', 'Alexandru', 1854071523456, TO_DATE(sysdate, 'YYYY-MM-DD'), 3950);

-- EX9
create or replace procedure ex9_procedura 
    (v_nume_magazin magazine.nume%type default 'Nume magazin')
is 
    v_id_locatie magazine.id_locatie%type;
    v_oras locatii.oras%type;
     
    type rec_tablou_produse is record (
        nume_client clienti.nume%type,
        prenume_client clienti.prenume%type,
        id_produs produs_magazin.id_produs%type,
        nume_produs produse.nume_produs%type,
        stoc produs_magazin.stoc%type
    );
    
    type tablou_produse is table of rec_tablou_produse;
    t_produse tablou_produse := tablou_produse();
    
    magazinul_nu_are_produse exception;
    
begin
     begin
        select m.id_locatie, oras into v_id_locatie, v_oras
        from magazine m, locatii l
        where upper(v_nume_magazin) = upper(m.nume)
        and m.id_locatie = l.id_locatie;
    exception
        when no_data_found
            then raise_application_error(-20000, 'Nu exista niciun magazin cu numele ' 
            || v_nume_magazin);
        when too_many_rows
            then raise_application_error(-20001, 'Exista mai multe magazine cu numele '
            || v_nume_magazin);
    end;
    
    begin
        select cl.nume, cl.prenume, pm.id_produs, p.nume_produs, pm.stoc 
        bulk collect into t_produse
        from produs_magazin pm, produse p, magazine m, comenzi com, clienti cl
        where p.id_produs = pm.id_produs
        and pm.id_magazin = m.id_magazin
        and m.id_magazin = com.id_magazin
        and com.id_client = cl.id_client
        and m.nume = v_nume_magazin
        and m.id_locatie = v_id_locatie;
        
        if t_produse.count = 0
            then raise magazinul_nu_are_produse;
        end if;
        
        dbms_output.put_line('In magazinul ' || v_nume_magazin || ' din '
            || v_oras || ' gasim urmatoarele produse: ');
        for i in t_produse.first..t_produse.last loop
            dbms_output.put_line('(ID: ' || t_produse(i).id_produs || ') ' ||
                t_produse(i).stoc || ' x ' || t_produse(i).nume_produs);
        end loop;
        
        dbms_output.put_line(t_produse(1).nume_client || ' ' || 
            t_produse(1).prenume_client || ' a comandat de la acest magazin');
        
    exception
        when magazinul_nu_are_produse
            then dbms_output.put_line('Magazinul ' || v_nume_magazin
                || ' nu are niciun produs');
    end;
end ex9_procedura;
/
begin
    ex9_procedura;
end;
/
begin
    ex9_procedura('DVD Delight Cluj-Napoca');
end;
/
begin
    ex9_procedura('Just Watch Oradea');
end;
/
begin
    ex9_procedura('Popcorn Time Oradea');
end;
/

-- EX8
create or replace function ex8_functie 
    (v_id_magazin magazine.id_magazin%type default 6000)
return varchar2 is
    v_nume_manager angajati.nume%type;
    v_prenume_manager angajati.prenume%type;
    v_oras locatii.oras%type;
    
    fara_manager exception;
    in_afara_munteniei exception;
    fara_manager_in_afara_munteniei exception;
rezultat varchar2(1024);
begin
    begin
        select a.nume, a.prenume, oras into v_nume_manager, v_prenume_manager, v_oras
        from angajati a, locatii l, magazine m
        where a.id_angajat (+) = m.id_manager
        and m.id_locatie = l.id_locatie
        and m.id_magazin = v_id_magazin;

        if v_nume_manager is null and v_prenume_manager is null
            then if upper(v_oras) not in ('ARGES', 'BRAILA', 'BUZAU', 'CALARASI', 'DAMBOVITA',
                'GIURGIU', 'IALOMITA', 'ILFOV', 'PRAHOVA', 'TELEORMAN')
                then raise fara_manager_in_afara_munteniei;
            end if;
        end if;
        
        if v_nume_manager is null and v_prenume_manager is null
            then raise fara_manager;
        end if;
        
        if upper(v_oras) not in ('ARGES', 'BRAILA', 'BUZAU', 'CALARASI', 'DAMBOVITA',
            'GIURGIU', 'IALOMITA', 'ILFOV', 'PRAHOVA', 'TELEORMAN')
            then raise in_afara_munteniei;
        end if;
        
        rezultat := 'Magazinul cu ID ' || v_id_magazin || ' are ca manager pe ' ||
            v_nume_manager || ' ' || v_prenume_manager || ' ' || ' si se afla in ' ||
            'orasul ' || v_oras;
           
        exception
            when no_data_found
                then dbms_output.put_line('Magazinul cu ID ' || v_id_magazin ||
                    ' nu exista');
            when fara_manager
                then dbms_output.put_line('Magazinul cu ID ' || v_id_magazin ||
                    ' nu are manager');
            when in_afara_munteniei
                then dbms_output.put_line('Magazinul cu ID ' || v_id_magazin ||
                    ' nu se afla in Muntenia');
            when fara_manager_in_afara_munteniei
                then dbms_output.put_line('Magazinul cu ID ' || v_id_magazin ||
                    ' nu are manager si nu se afla in Muntenia');
    end;
    
    return rezultat;
    
end ex8_functie;
/
begin
    dbms_output.put_line(ex8_functie(2009));
end;
/
begin
    dbms_output.put_line(ex8_functie(2077));
end;
/
begin
    dbms_output.put_line(ex8_functie(2002));
end;
/
begin
    dbms_output.put_line(ex8_functie(2007));
end;
/
begin
    dbms_output.put_line(ex8_functie(2006));
end;
/

-- EX7 -- ciclu cursor
create or replace procedure ex7_subprogram_stocat_independent is 
    cursor m is select id_magazin, nume
                from magazine;
    cursor a (param magazine.id_magazin%type) is
            select nume, prenume, cnp
            from angajati
            where id_magazin = param;
            
    v_id_magazin magazine.id_magazin%type;
    v_nume_magazin magazine.nume%type;
            
begin
    open m;
    loop
        fetch m into v_id_magazin, v_nume_magazin;
        exit when m%notfound;
        
        dbms_output.put_line('-----------------------------------------------');
        dbms_output.put_line('Magazinul ' || v_nume_magazin);
        dbms_output.put_line('-----------------------------------------------');
        
        for i in a(v_id_magazin) loop
            dbms_output.put_line(i.nume || ' ' || i.prenume);
        end loop;
    end loop;
    close m;
end ex7_subprogram_stocat_independent;
/

begin
    ex7_subprogram_stocat_independent;
end;
/

-- EX6
create or replace procedure ex6_subprogram_stocat_independent
    (v_nume_oras locatii.oras%type default 'Buzau')
is
    type cl_com_rec is record (
        Nume CLIENTI.NUME%TYPE,
        Prenume CLIENTI.PRENUME%TYPE,
        Status_comanda COMENZI.STATUS_COMANDA%TYPE
    );
    
    -- tablou indexat
    type tablou_indexat is table of cl_com_rec
    index by pls_integer;
    t_indexat tablou_indexat;
    
    -- tablou imbricat
    type tablou_imbricat is table of angajati%rowtype;
    t_imbricat tablou_imbricat := tablou_imbricat();
    
    -- vector
    type vector is varray(20) of locatii.oras%type; 
    t_vector vector := vector();
    
    v_oras locatii.oras%type;
begin
    -- tablou indexat
    for i in (
            select nume, prenume, status_comanda
            from clienti cl, comenzi com
            where cl.id_client = com.id_client
    ) loop       
        t_indexat(t_indexat.count + 1).Nume := i.Nume;
        t_indexat(t_indexat.count).Prenume := i.Prenume;
        t_indexat(t_indexat.count).Status_comanda := i.Status_comanda;
    end loop;
    for i in t_indexat.first..t_indexat.last loop
        dbms_output.put_line(t_indexat(i).nume || ' ' || t_indexat(i).prenume 
            || ' ' || t_indexat(i).status_comanda);
    end loop;
    dbms_output.new_line;
    
    -- tablou imbricat
    for i in (
            select *
            from (
                select *
                from angajati
                order by salariu desc
            ) Top10Salarii
            where rownum <= 10
    ) loop
        t_imbricat.extend;
        t_imbricat(t_imbricat.count) := i;
    end loop;
    for i in t_imbricat.first..t_imbricat.last loop
        dbms_output.put_line(t_imbricat(i).nume || ' ' || t_imbricat(i).salariu);
    end loop;
    dbms_output.new_line;
    
    -- vector
    for i in (
        select oras
        from locatii l, magazine m
        where l.id_locatie = m.id_locatie
        order by oras
    ) loop
        t_vector.extend;
        t_vector(t_vector.count) := i.oras;
    end loop;
    
    for i in t_vector.first..t_vector.last loop
        dbms_output.put_line(i || ' ' || t_vector(i));
    end loop;
    
    select oras into v_oras
    from locatii
    where upper(oras) = upper(v_nume_oras);
    dbms_output.put_line('In ' || v_nume_oras || ' exista un magazin');
    exception
        when no_data_found then
            dbms_output.put_line('Nu exista magazine in ' || v_nume_oras);
        WHEN TOO_MANY_ROWS THEN 
            dbms_output.put_line('Exista mai multe magazine in ' || v_nume_oras);
        WHEN OTHERS THEN 
            dbms_output.put_line('Alta eroare');
end ex6_subprogram_stocat_independent;
/

begin
    ex6_subprogram_stocat_independent;
end;
/

-- pentru fiecare client, lista magazinelor in care a plasat comenzi
-- cursor client
-- cursor parametrizat pentru magazine

declare
    cursor cl is
        select id_client
        from clienti;
        
    cursor m (param clienti.id_client%type) is
        select m.id_magazin
        from magazine m, clienti cl, comenzi com
        where cl.id_client = com.id_client
        and com.id_magazin = m.id_magazin;
begin
    for c in cl loop
        dbms_output.put_line('client' || c.id_client);
        for mag in m(c.id_client) loop
            dbms_output.put_line(mag.id_magazin || ' ');
        end loop;
    end loop;
end;
/








