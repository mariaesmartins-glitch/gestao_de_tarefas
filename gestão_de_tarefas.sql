CREATE TABLE colaboradores (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(50) NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE categorias (
    id_categoria SERIAL PRIMARY KEY,
    nome VARCHAR(80) UNIQUE NOT NULL,
    descricao TEXT
);

CREATE TABLE tarefas (
    id SERIAL PRIMARY KEY,
    categoria_id INTEGER NOT NULL REFERENCES categorias(id_categoria),
    colaborador_id INTEGER NOT NULL REFERENCES colaboradores(id),
    titulo VARCHAR(150) NOT NULL,
    descricao TEXT,
    data_agendamento DATE NOT NULL,
    prazo_entrega DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'Pendente'
        CHECK (status IN ('Pendente', 'Em Andamento', 'Concluida', 'Cancelada')),
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE historico_tarefas (
    id SERIAL PRIMARY KEY,
    tarefa_id INTEGER NOT NULL REFERENCES tarefas(id) ON DELETE CASCADE,
    observacao VARCHAR(200) NOT NULL,
    data_alteracao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO colaboradores (nome, email, senha, ativo)
VALUES
('Regiane dos Santos', 'regiane.santos@email.com', '754356', TRUE),
('Neusa Maria Santos', 'neusa.maria@email.com', '432344', TRUE),
('Maria Eduarda', 'maria.e@email.com', '457874', FALSE);

INSERT INTO categorias (nome, descricao)
VALUES
('Planejamento', 'Organizacao de projetos'),
('Desenvolvimento', 'Execucao de atividades'),
('Documentacao', 'Criacao de relatorios');

INSERT INTO tarefas
(categoria_id, colaborador_id, titulo, descricao,
 data_agendamento, prazo_entrega, status)
VALUES
(1, 1, 'Organizar projeto', 'Planejar as etapas',
 '2026-11-20', '2026-11-25', 'Pendente'),
(2, 2, 'Desenvolver sistema', 'Criar o sistema',
 '2026-11-21', '2026-11-30', 'Em Andamento'),
(3, 1, 'Criar relatorio', 'Documentar resultados',
 '2026-11-22', '2026-12-05', 'Pendente');

INSERT INTO historico_tarefas (tarefa_id, observacao)
VALUES
(1, 'Tarefa cadastrada no sistema'),
(2, 'Tarefa cadastrada no sistema'),
(3, 'Tarefa cadastrada no sistema');

CREATE OR REPLACE FUNCTION fn_buscar_colaboradores(
    p_termo TEXT
)
RETURNS TABLE (
    id INTEGER,
    nome VARCHAR(100),
    email VARCHAR(100),
    ativo BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id,
        c.nome,
        c.email,
        c.ativo
    FROM colaboradores c
    WHERE c.nome ILIKE '%' || p_termo || '%'
       OR c.email ILIKE '%' || p_termo || '%'
    ORDER BY c.nome;
END;
$$;

CREATE OR REPLACE FUNCTION fn_validar_tarefa()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_ativo BOOLEAN;
BEGIN
    SELECT c.ativo
    INTO v_ativo
    FROM colaboradores c
    WHERE c.id = NEW.colaborador_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Colaborador nao encontrado.';
    END IF;

    IF v_ativo = FALSE THEN
        RAISE EXCEPTION 'Nao e permitido atribuir tarefas a colaboradores inativos.';
    END IF;

    NEW.data_criacao := CURRENT_TIMESTAMP;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validar_tarefa
BEFORE INSERT ON tarefas
FOR EACH ROW
EXECUTE FUNCTION fn_validar_tarefa();

CREATE OR REPLACE FUNCTION fn_registrar_historico()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO historico_tarefas
    (tarefa_id, observacao)
    VALUES
    (NEW.id, 'Tarefa cadastrada no sistema. Status: ' || NEW.status);

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_registrar_historico
AFTER INSERT ON tarefas
FOR EACH ROW
EXECUTE FUNCTION fn_registrar_historico();

CREATE OR REPLACE VIEW vw_painel_principal AS
SELECT
    c.nome AS nome_colaborador,
    t.titulo AS titulo_tarefa,
    cat.nome AS categoria,
    t.prazo_entrega,
    t.status
FROM tarefas t
INNER JOIN colaboradores c
    ON t.colaborador_id = c.id
INNER JOIN categorias cat
    ON t.categoria_id = cat.id_categoria;

    CREATE OR REPLACE VIEW vw_cronograma_prazos AS
SELECT
    t.id AS tarefa_id,
    t.titulo AS titulo_tarefa,
    c.nome AS nome_responsavel,
    t.data_agendamento,
    t.prazo_entrega,
    t.status,
    (t.prazo_entrega - CURRENT_DATE) AS dias_restantes
FROM tarefas t
INNER JOIN colaboradores c
    ON t.colaborador_id = c.id
ORDER BY t.prazo_entrega ASC, t.id ASC;

INSERT INTO tarefas
(categoria_id, colaborador_id, titulo, descricao,
 data_agendamento, prazo_entrega, status)
VALUES
(1, 1, 'Organizar projeto', 'Planejar as etapas',
 '2026-11-20', '2026-11-25', 'Pendente'),

(2, 2, 'Desenvolver sistema', 'Criar o sistema',
 '2026-11-21', '2026-11-30', 'Em Andamento'),

(3, 1, 'Criar relatorio', 'Documentar resultados',
 '2026-11-22', '2026-12-05', 'Pendente');
