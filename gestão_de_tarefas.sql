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
);

CREATE TABLE tarefas (
    id SERIAL PRIMARY KEY,
    categoria_id INTEGER REFERENCES categorias(id),
    colaborador_id INTEGER REFERENCES colaboradores(id),
    titulo VARCHAR(150) NOT NULL,
    descrição TEXT,
    data_agendamento DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'Pendente' CHECK (status IN ('Pendente', 'Em Andamento', 'Concluida', 'Cancelada')),
    data_criação TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE historico_tarefas (
    id SERIAL PRIMARY KEY,
    tarefa_id INTEGER REFERENCES tarefas(id) ON DELETE CASCADE,
    observação VARCHAR(200) NOT NULL,
    data_alteração TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO colaboradores (nome, email, senha, ativo)
VALUES
('Regiane dos Santos', 'regiane.santos@email.com', '754356', TRUE),
('Neusa Maria Santos', 'neusa.maria@email.com', '432344', TRUE),
('Maria Eduarda', 'maria.e@email.com', '457874', FALSE);

SELECT * FROM
colaboradores

INSERT INTO categorias (nome, descricao)
VALUES
('Planejamento', 'Organização de projetos'),
('Desenvolvimento', 'Execução de atividades'),
('Documentação', 'Criação de relatórios');

SELECT * FROM
categorias

INSERT INTO tarefas (categoria_id, colaborador_id, titulo, descricao, data_agendamento, status) VALUES
(1, 1, 'Organizar projeto', 'Planejar as etapas', '13/10/2025', 'Concluída'),
(2, 2, 'Desenvolver sistema', 'Criar o sistema', '30/09/2026', 'Em Andamento'),
(3, 1, 'Criar relatório', 'Documentar resultados', '11/11/2026', 'Pendente');

SELECT * FROM
tarefas

INSERT INTO historico_tarefas (tarefa_id, observação)
VALUES
(1, 'Tarefa cadastrada no sistema'),
(2, 'Tarefa cadastrada no sistema'),
(3, 'Tarefa cadastrada no sistema');