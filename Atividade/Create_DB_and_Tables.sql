DROP DATABASE [SIGAA]

CREATE DATABASE [SIGAA];

GO
print 'Criado Banco de Dados SIGAA'

USE [SIGAA];
GO

CREATE TABLE [Disciplinas](
    COD_DISC   INT          NOT NULL CHECK (COD_DISC > 0)
    , QTD_CRED TINYINT      NOT NULL
    , NOM_DISC VARCHAR(60)  NOT NULL
    
    CONSTRAINT DISC_PK PRIMARY KEY(COD_DISC)
);
GO
print 'Criada Tabelas Disciplinas'

CREATE TABLE [Pre_Requisitos](
    COD_DISC       INT NOT NULL CHECK (COD_DISC > 0)
    , COD_DISC_PRE INT NOT NULL  CHECK (COD_DISC_PRE > 0)

    CONSTRAINT PRE_REQ_PK PRIMARY KEY(COD_DISC, COD_DISC_PRE)
    , CONSTRAINT PRE_REQ_FK_DISC FOREIGN KEY(COD_DISC) REFERENCES Disciplinas(COD_DISC)
    , CONSTRAINT PRE_REQ_FK_DISC_PRE FOREIGN KEY(COD_DISC) REFERENCES Disciplinas(COD_DISC)
    , CONSTRAINT PRE_REQ_CHECK_NOT_EQUALS CHECK (COD_DISC != COD_DISC_PRE)
);
GO
print 'Criada Tabelas Pre_Requisitos'

CREATE TABLE [Cursos](
    COD_CURSO   TINYINT     NOT NULL CHECK (COD_CURSO > 0)
    , TOT_CRED  INT         NOT NULL
    , NOM_CURSO VARCHAR(60) NOT NULL
    , COD_COORD             INT

    CONSTRAINT CURSO_PK PRIMARY KEY(COD_CURSO)
    --, CONSTRAINT CURSO_FK_COORD FOREIGN KEY(COD_COORD) REFERENCES Professores(COD_PROF)
      , CONSTRAINT CURSO_CHECK_CREDITO_TOTAL CHECK(TOT_CRED <= 220) --LISTA:Q4
    
);
GO
print 'Criada Tabelas Cursos'

CREATE TABLE [Professores](
    COD_PROF    INT         NOT NULL CHECK (COD_PROF > 0)
    , COD_CURSO TINYINT     NOT NULL --CHECK (COD_CURSO > 0)
    , NOM_PROF  VARCHAR(60) NOT NULL

    CONSTRAINT PROF_PK PRIMARY KEY(COD_PROF)
    , CONSTRAINT PROF_FK_CURSO FOREIGN KEY(COD_CURSO) REFERENCES Cursos(COD_CURSO)  
);
GO
print 'Criada Tabelas Professores'

ALTER TABLE [Cursos] ADD  CONSTRAINT CURSO_FK_COORD FOREIGN KEY(COD_COORD) REFERENCES Professores(COD_PROF);
GO
print 'Alteração Na Tabela Professor -- add CURSO_FK_COORD'

CREATE TABLE [Alunos](
    MAT_ALU     INT    NOT NULL CHECK (MAT_ALU > 0)
    , COD_CURSO TINYINT    NOT NULL --CHECK (COD_CURSO > 0)
    , DAT_NASC  DATE         NOT NULL
    , TOT_CRED  INT    NOT NULL
    , MGP       NUMERIC(4, 2) NOT NULL
    , NOM_ALU   VARCHAR(60)  NOT NULL

    CONSTRAINT ALUNOS_PK PRIMARY KEY(MAT_ALU)
    , CONSTRAINT ALUNOS_FK_CURSO FOREIGN KEY(COD_CURSO) REFERENCES Cursos(COD_CURSO)
    , CONSTRAINT ALUNOS_CHECK_IDADES CHECK (DATEDIFF(YEAR,DAT_NASC, GETDATE() ) >= 16) --LISTA:Q16
);
GO
print 'Criada Tabelas Alunos'

CREATE TABLE [Curriculos](
    COD_CURSO  TINYINT NOT NULL --CHECK (COD_CURSO > 0)
    , COD_DISC INT NOT NULL --CHECK (COD_DISC > 0)
    , PERIODO  TINYINT NOT NULL 

    CONSTRAINT CURRICULO_PK PRIMARY KEY(COD_CURSO, COD_DISC)
    , CONSTRAINT CURRICULO_FK_CURSO FOREIGN KEY(COD_CURSO) REFERENCES Cursos(COD_CURSO)
    , CONSTRAINT CURRICULO_FK_DISC FOREIGN KEY(COD_DISC) REFERENCES Disciplinas(COD_DISC)   

);
GO
print 'Criada Tabelas Curriculos'

CREATE TABLE [Historicos_Escolares](
    ANO        INT   NOT NULL 
    , SEMESTRE TINYINT   NOT NULL CHECK (SEMESTRE IN (1, 2))
    , COD_DISC INT   NOT NULL --CHECK (COD_DISC > 0)
    , MAT_ALU  INT   NOT NULL --CHECK (MAT_ALU > 0)
    , MEDIA    NUMERIC(4,2) NOT NULL
    , FALTAS   INT   NOT NULL
    , SITUACAO CHAR(2)     NOT NULL CHECK (SITUACAO IN ('AP', 'RF', 'RM'))
    
    CONSTRAINT HIST_ESC_PK PRIMARY KEY(ANO, SEMESTRE, COD_DISC, MAT_ALU )
    , CONSTRAINT HIST_ESC_FK_DISC FOREIGN KEY(COD_DISC) REFERENCES Disciplinas(COD_DISC)
    , CONSTRAINT HIST_ESC_FK_ALUNO FOREIGN KEY(MAT_ALU) REFERENCES Alunos(MAT_ALU)
);
GO
print 'Criada Tabelas Historicos_Escolares'

CREATE TABLE [Turmas](
    ANO INT NOT NULL
    , SEMESTRE  TINYINT NOT NULL CHECK (SEMESTRE IN (1, 2))
    , COD_DISC  INT     NOT NULL --CHECK (COD_DISC > 0)
    , TURMA     CHAR(3) NOT NULL
    , TOT_VAGAS INT     NOT NULL
    , VAG_OCUP  INT     NOT NULL
    , COD_PROF  INT

    CONSTRAINT TURMA_PK PRIMARY KEY(ANO, TURMA, SEMESTRE, COD_DISC)
    , CONSTRAINT TURMA_FK_DISC FOREIGN KEY(COD_DISC) REFERENCES Disciplinas(COD_DISC)
    -- 11. O total de vagas ocupadas não deve ser superior ao total de vagas disponíveis;
    , CONSTRAINT TURMA_CHECK_VARGAS CHECK (TOT_VAGAS >= VAG_OCUP)
);
GO
print 'Criada Tabelas Turmas'

CREATE TABLE [Tumas_Matriculadas](
    ANO INT NOT NULL
    , SEMESTRE  TINYINT  NOT NULL --CHECK (SEMESTRE IN (1, 2))
    , COD_DISC  INT      NOT NULL --CHECK(COD_DISC > 0)
    , TURMA     CHAR(3)  NOT NULL
    , MAT_ALU   INT      NOT NULL --CHECK(MAT_ALU > 0)
    , NOTA_1    NUMERIC(3, 1)
    , NOTA_2    NUMERIC(3, 1)
    , NOTA_3    NUMERIC(3, 1)
    , NOTA_4    NUMERIC(3, 1)
    , FALTAS_1  INT
    , FALTAS_2  INT
    , FALTAS_3  INT

    CONSTRAINT TURM_MAT_PK PRIMARY KEY(ANO, SEMESTRE, COD_DISC, TURMA, MAT_ALU)
    , CONSTRAINT TURM_MAT_FK_TURM FOREIGN KEY(ANO, TURMA, SEMESTRE, COD_DISC) REFERENCES Turmas(ANO, TURMA, SEMESTRE, COD_DISC)
    --, CONSTRAINT TURM_MAT_FK_TURM_SEMEST FOREIGN KEY(SEMESTRE) REFERENCES Turmas(SEMESTRE)
    --, CONSTRAINT TURM_MAT_FK_TURM_ADISC FOREIGN KEY(COD_DISC) REFERENCES Turmas(COD_DISC)
    --, CONSTRAINT TURM_MAT_FK_TURM FOREIGN KEY(TURMA) REFERENCES Turmas(TURMA)
    ---, CONSTRAINT TT_FK FOREIGN KEY(FALTAS_1) REFERENCES Turmas(SEMESTRE)
    , CONSTRAINT TURM_MAT_FK_MAT_ALU FOREIGN KEY(MAT_ALU) REFERENCES Alunos(MAT_ALU)

);
GO
print 'Criada Tabelas Tumas_Matriculadas'