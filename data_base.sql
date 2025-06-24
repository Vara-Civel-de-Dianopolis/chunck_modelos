-- Tabela para armazenar informações dos documentos jurídicos
    CREATE TABLE IF NOT EXISTS documents (
        id INT AUTO_INCREMENT PRIMARY KEY,
        file_path VARCHAR(1000) UNIQUE NOT NULL,
        file_name VARCHAR(500) NOT NULL,
        file_type VARCHAR(50) NOT NULL,
        file_size BIGINT,
        content_length INT,
        file_hash VARCHAR(32) NOT NULL,
        modification_timestamp DOUBLE NOT NULL,
        chapters_count INT DEFAULT 0,
        upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        last_processed TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        status ENUM('pending', 'processed', 'error') DEFAULT 'pending',
        
        INDEX idx_file_path (file_path),
        INDEX idx_file_hash (file_hash),
        INDEX idx_modification_timestamp (modification_timestamp),
        INDEX idx_status (status),
        INDEX idx_chapters_count (chapters_count)
    );

    -- Tabela para armazenar informações dos capítulos detectados
    CREATE TABLE IF NOT EXISTS document_chapters (
        id INT AUTO_INCREMENT PRIMARY KEY,
        document_id INT NOT NULL,
        chapter_index INT NOT NULL,
        title VARCHAR(500) NOT NULL,
        chapter_type ENUM('CAPITULO', 'SECAO', 'SUBSECAO', 'ARTIGO', 'DISPOSITIVO', 'FUNDAMENTACAO', 'TITULO', 'DOCUMENTO') NOT NULL,
        level INT NOT NULL,
        start_position INT NOT NULL,
        end_position INT,
        content_preview TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        
        FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE,
        INDEX idx_document_chapters (document_id, chapter_index),
        INDEX idx_chapter_type (chapter_type),
        INDEX idx_chapter_level (level),
        FULLTEXT INDEX idx_chapter_title (title)
    );

    -- Tabela para armazenar os chunks organizados por capítulos
    CREATE TABLE IF NOT EXISTS document_chunks (
        id INT AUTO_INCREMENT PRIMARY KEY,
        document_id INT NOT NULL,
        chunk_index INT NOT NULL,
        content TEXT NOT NULL,
        chunk_size INT NOT NULL,
        start_position INT NOT NULL,
        end_position INT NOT NULL,
        overlap_size INT DEFAULT 0,
        chapter_title VARCHAR(500),
        chapter_type ENUM('CAPITULO', 'SECAO', 'SUBSECAO', 'ARTIGO', 'DISPOSITIVO', 'FUNDAMENTACAO', 'TITULO', 'DOCUMENTO'),
        chapter_level INT,
        absolute_start_position INT,
        absolute_end_position INT,
        is_chapter_complete BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        
        FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE,
        INDEX idx_document_id (document_id),
        INDEX idx_chunk_index (document_id, chunk_index),
        INDEX idx_chapter_info (chapter_type, chapter_level),
        FULLTEXT INDEX idx_content (content),
        FULLTEXT INDEX idx_chapter_title (chapter_title)
    );

    -- Tabela para armazenar metadados adicionais dos chunks
    CREATE TABLE IF NOT EXISTS chunk_metadata (
        id INT AUTO_INCREMENT PRIMARY KEY,
        chunk_id INT NOT NULL,
        metadata_key VARCHAR(100) NOT NULL,
        metadata_value TEXT,
        
        FOREIGN KEY (chunk_id) REFERENCES document_chunks(id) ON DELETE CASCADE,
        INDEX idx_chunk_metadata (chunk_id, metadata_key)
    );

    -- Tabela para logs de processamento
    CREATE TABLE IF NOT EXISTS processing_logs (
        id INT AUTO_INCREMENT PRIMARY KEY,
        document_id INT,
        operation VARCHAR(100) NOT NULL,
        status ENUM('success', 'error', 'warning') NOT NULL,
        message TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        
        FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE SET NULL,
        INDEX idx_document_logs (document_id),
        INDEX idx_operation (operation),
        INDEX idx_status (status)
    );
