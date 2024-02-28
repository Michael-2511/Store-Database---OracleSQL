create table Angajati (
    ID_Angajat number(4),
    ID_Magazin number(4) not null,
    Nume varchar2(25) not null,
    Prenume varchar2(25) not null,
    CNP number(13) not null,
    Data_Angajare date default sysdate,
    Salariu number(5) default 1900,
    constraint PK_ID_Angajat primary key (ID_Angajat),
    constraint UQ_CNP unique (CNP),
    constraint CK_CNP check (length(CNP) = 13)
);
--------------------------------------------------------------------------------
create table Magazine (
    ID_Magazin number(4),
    ID_Locatie number(4) not null,
    Nume varchar(50),
    ID_Manager number(4),
    constraint PK_ID_Magazin primary key (ID_Magazin)
);
--------------------------------------------------------------------------------
create table Locatii (
    ID_Locatie number(4),
    Oras varchar2(20) not null,
    Strada varchar2(20) not null,
    Numar number(4) not null,
    constraint PK_ID_Locatie primary key (ID_Locatie)
);

--Magazine
ALTER TABLE Magazine
ADD CONSTRAINT FK_ID_Manager FOREIGN KEY (ID_Manager) REFERENCES Angajati(ID_Angajat);

ALTER TABLE Magazine
ADD CONSTRAINT FK_ID_Locatie FOREIGN KEY (ID_Locatie) REFERENCES Locatii(ID_Locatie);
--------------------------------------------------------------------------------
create table Produse (
    ID_Produs number(4),
    Tip_Produs varchar(20),
    Nume_Produs varchar(50),
    Pret number(3),
    constraint PK_ID_Produs primary key (ID_Produs)
);
--------------------------------------------------------------------------------
create table Clienti (
    ID_Client number(6),
    Nume varchar2(25),
    Prenume varchar2(25),
    Email varchar2(50),
    constraint PK_ID_Client primary key (ID_Client)
);
--------------------------------------------------------------------------------
create table Comenzi (
    ID_Comanda number(6),
    ID_Magazin number(4),
    ID_Client number(6),
    Data_Plasare_Comanda date default sysdate,
    Data_Livrare_Comanda date,
    Status_Comanda varchar2(100),
    constraint PK_ID_Comanda primary key (ID_Comanda)
);

ALTER TABLE Comenzi
ADD CONSTRAINT FK_ID_Magazin_Comenzi FOREIGN KEY (ID_Magazin) REFERENCES Magazine(ID_Magazin);

ALTER TABLE Comenzi
ADD CONSTRAINT FK_ID_Client FOREIGN KEY (ID_Client) REFERENCES Clienti(ID_Client);
--------------------------------------------------------------------------------
create table Produs_Magazin (
    ID_Produs number(4),
    ID_Magazin number(4) not null,
    Stoc number(4)
);

ALTER TABLE Produs_Magazin
ADD CONSTRAINT FK_ID_Produs_Magazin FOREIGN KEY (ID_Produs) REFERENCES Produse(ID_Produs);

ALTER TABLE Produs_Magazin
ADD CONSTRAINT FK_ID_Magazin_Produs FOREIGN KEY (ID_Magazin) REFERENCES Magazine(ID_Magazin);
--------------------------------------------------------------------------------
create table Produs_Comanda (
    ID_Produs number(4),
    ID_Comanda number(6),
    Cantitate number(3)
);

ALTER TABLE Produs_Comanda
ADD CONSTRAINT FK_ID_Produs_Comanda FOREIGN KEY (ID_Produs) REFERENCES Produse(ID_Produs);

ALTER TABLE Produs_Comanda
ADD CONSTRAINT FK_ID_Comanda FOREIGN KEY (ID_Comanda) REFERENCES Comenzi(ID_Comanda);