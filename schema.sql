
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    location VARCHAR(255),
    experience_years INTEGER DEFAULT 0,
    profile_summary TEXT,
    resume_url VARCHAR(512),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Admins Table (Employers/Job Posters)
CREATE TABLE admins (
    admin_id SERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    company_name VARCHAR(255) NOT NULL,
    company_location VARCHAR(255),
    company_headquarters VARCHAR(255),
    company_website VARCHAR(255),
    contact_phone VARCHAR(20),
    company_description TEXT,
    industry VARCHAR(100),
    company_size VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Jobs Table
CREATE TABLE jobs (
    job_id SERIAL PRIMARY KEY,
    admin_id INTEGER NOT NULL,
    job_title VARCHAR(255) NOT NULL,
    job_description TEXT,
    job_location VARCHAR(255) NOT NULL,
    job_type VARCHAR(50) DEFAULT 'Full-time', -- e.g., "Full-time", "Part-time", "Contract", "Internship"
    salary_min INTEGER,
    salary_max INTEGER,
    currency VARCHAR(10) DEFAULT 'USD',
    experience_required INTEGER DEFAULT 0, -- Years of experience
    education_level VARCHAR(100), -- e.g., "Bachelor's", "Master's", "PhD"
    remote_option BOOLEAN DEFAULT FALSE,
    requirements TEXT,
    responsibilities TEXT,
    benefits TEXT,
    application_deadline TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    views_count INTEGER DEFAULT 0,
    FOREIGN KEY (admin_id) REFERENCES admins(admin_id) ON DELETE CASCADE
);

-- Skills Table
CREATE TABLE skills (
    skill_id SERIAL PRIMARY KEY,
    skill_name VARCHAR(100) UNIQUE NOT NULL,
    category VARCHAR(50), -- e.g., "Technical", "Soft Skills", "Languages", "Tools"
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User Skills (Candidate Skills)
CREATE TABLE user_skills (
    user_skill_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    skill_id INTEGER NOT NULL,
    proficiency_level VARCHAR(50), -- e.g., "Beginner", "Intermediate", "Advanced", "Expert"
    years_of_experience DECIMAL(3,1),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE,
    UNIQUE (user_id, skill_id)
);

-- Job Skills (Required/Preferred Skills for Jobs)
CREATE TABLE job_skills (
    job_skill_id SERIAL PRIMARY KEY,
    job_id INTEGER NOT NULL,
    skill_id INTEGER NOT NULL,
    is_required BOOLEAN DEFAULT TRUE, -- TRUE for required, FALSE for preferred
    proficiency_level VARCHAR(50), -- Minimum required proficiency
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (job_id) REFERENCES jobs(job_id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills(skill_id) ON DELETE CASCADE,
    UNIQUE (job_id, skill_id)
);

-- Job Applications
CREATE TABLE job_applications (
    application_id SERIAL PRIMARY KEY,
    job_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    cover_letter TEXT,
    application_status VARCHAR(50) DEFAULT 'Applied', -- e.g., "Applied", "Under Review", "Interview", "Rejected", "Accepted"
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT, -- Admin notes about the application
    match_score DECIMAL(5,2), -- Matching percentage
    FOREIGN KEY (job_id) REFERENCES jobs(job_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE (job_id, user_id)
);

-- User Education
CREATE TABLE user_education (
    education_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    institution_name VARCHAR(255) NOT NULL,
    degree VARCHAR(100) NOT NULL,
    field_of_study VARCHAR(100),
    start_date DATE,
    end_date DATE,
    grade VARCHAR(20),
    is_current BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- User Experience
CREATE TABLE user_experience (
    experience_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    job_title VARCHAR(255) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    is_current BOOLEAN DEFAULT FALSE,
    description TEXT,
    location VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Resume Analysis
CREATE TABLE resume_analysis (
    analysis_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    resume_url VARCHAR(512) NOT NULL,
    analysis_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    overall_score DECIMAL(5,2),
    strengths JSONB, -- Array of strengths
    weaknesses JSONB, -- Array of weaknesses/anomalies
    suggestions JSONB, -- Array of enhancement suggestions
    keywords_extracted JSONB, -- Array of extracted keywords
    format_issues JSONB, -- Array of formatting issues
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Job Matches (For Open Roles feature)
CREATE TABLE job_matches (
    match_id SERIAL PRIMARY KEY,
    job_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    match_score DECIMAL(5,2) NOT NULL,
    matched_skills JSONB,
    missing_skills JSONB,
    match_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_viewed BOOLEAN DEFAULT FALSE,
    is_dismissed BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (job_id) REFERENCES jobs(job_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE (job_id, user_id)
);

-- Saved Searches
CREATE TABLE saved_searches (
    search_id SERIAL PRIMARY KEY,
    user_id INTEGER,
    admin_id INTEGER,
    search_name VARCHAR(255) NOT NULL,
    search_criteria JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    CHECK ((user_id IS NOT NULL AND admin_id IS NULL) OR (user_id IS NULL AND admin_id IS NOT NULL)),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (admin_id) REFERENCES admins(admin_id) ON DELETE CASCADE
);

-- Notifications
CREATE TABLE notifications (
    notification_id SERIAL PRIMARY KEY,
    user_id INTEGER,
    admin_id INTEGER,
    notification_type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    related_entity_type VARCHAR(50),
    related_entity_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK ((user_id IS NOT NULL AND admin_id IS NULL) OR (user_id IS NULL AND admin_id IS NOT NULL)),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (admin_id) REFERENCES admins(admin_id) ON DELETE CASCADE
);

-- Admin Performance Metrics
CREATE TABLE admin_performance (
    performance_id SERIAL PRIMARY KEY,
    admin_id INTEGER NOT NULL,
    total_jobs_posted INTEGER DEFAULT 0,
    active_jobs INTEGER DEFAULT 0,
    total_applications_received INTEGER DEFAULT 0,
    total_hires INTEGER DEFAULT 0,
    avg_time_to_hire INTEGER, -- in days
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES admins(admin_id) ON DELETE CASCADE
);

-- User Performance Metrics
CREATE TABLE user_performance (
    performance_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    profile_views INTEGER DEFAULT 0,
    applications_sent INTEGER DEFAULT 0,
    interviews_received INTEGER DEFAULT 0,
    offers_received INTEGER DEFAULT 0,
    avg_match_score DECIMAL(5,2),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Feature Flags
CREATE TABLE feature_flags (
    flag_id SERIAL PRIMARY KEY,
    feature_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    is_enabled BOOLEAN DEFAULT TRUE,
    applies_to VARCHAR(20) DEFAULT 'global', -- "global", "job", "user", "admin"
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Job Feature Overrides
CREATE TABLE job_feature_overrides (
    override_id SERIAL PRIMARY KEY,
    job_id INTEGER NOT NULL,
    flag_id INTEGER NOT NULL,
    is_enabled BOOLEAN NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (job_id) REFERENCES jobs(job_id) ON DELETE CASCADE,
    FOREIGN KEY (flag_id) REFERENCES feature_flags(flag_id) ON DELETE CASCADE,
    UNIQUE (job_id, flag_id)
);

-- Rejected Candidates (for candidate search filtering)
CREATE TABLE rejected_candidates (
    rejection_id SERIAL PRIMARY KEY,
    job_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    admin_id INTEGER NOT NULL,
    rejection_reason TEXT,
    rejected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (job_id) REFERENCES jobs(job_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (admin_id) REFERENCES admins(admin_id) ON DELETE CASCADE,
    UNIQUE (job_id, user_id)
);

-- ============================================
-- VIEWS
-- ============================================

-- Job Search View (as used in Flask app)
CREATE OR REPLACE VIEW job_search_view AS
SELECT 
    j.job_id,
    j.job_title,
    j.job_description,
    j.job_location,
    j.job_type,
    j.salary_min,
    j.salary_max,
    j.currency,
    j.experience_required,
    j.education_level,
    j.remote_option,
    j.created_at,
    j.is_active,
    a.company_name,
    a.email as company_email,
    a.company_headquarters,
    a.company_website,
    a.contact_phone,
    STRING_AGG(DISTINCT s.skill_name, ', ') as required_skills
FROM jobs j
JOIN admins a ON j.admin_id = a.admin_id
LEFT JOIN job_skills js ON j.job_id = js.job_id
LEFT JOIN skills s ON js.skill_id = s.skill_id
WHERE j.is_active = true
GROUP BY j.job_id, a.admin_id;

-- ============================================
-- FUNCTIONS
-- ============================================

-- Search Jobs Function (as used in Flask app)
CREATE OR REPLACE FUNCTION search_jobs(
    search_title TEXT DEFAULT NULL,
    search_location TEXT DEFAULT NULL,
    search_skills TEXT[] DEFAULT NULL,
    min_salary_filter INTEGER DEFAULT NULL,
    max_experience_filter INTEGER DEFAULT NULL,
    job_type_filter TEXT DEFAULT NULL,
    remote_only_filter BOOLEAN DEFAULT FALSE
)
RETURNS TABLE (
    job_id INTEGER,
    job_title VARCHAR,
    job_description TEXT,
    job_location VARCHAR,
    job_type VARCHAR,
    salary_min INTEGER,
    salary_max INTEGER,
    currency VARCHAR,
    experience_required INTEGER,
    education_level VARCHAR,
    remote_option BOOLEAN,
    created_at TIMESTAMP,
    company_name VARCHAR,
    company_email VARCHAR,
    company_headquarters VARCHAR,
    company_website VARCHAR,
    contact_phone VARCHAR,
    required_skills TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        jsv.job_id,
        jsv.job_title,
        jsv.job_description,
        jsv.job_location,
        jsv.job_type,
        jsv.salary_min,
        jsv.salary_max,
        jsv.currency,
        jsv.experience_required,
        jsv.education_level,
        jsv.remote_option,
        jsv.created_at,
        jsv.company_name,
        jsv.company_email,
        jsv.company_headquarters,
        jsv.company_website,
        jsv.contact_phone,
        jsv.required_skills
    FROM job_search_view jsv
    WHERE 
        (search_title IS NULL OR jsv.job_title ILIKE '%' || search_title || '%')
        AND (search_location IS NULL OR jsv.job_location ILIKE '%' || search_location || '%')
        AND (min_salary_filter IS NULL OR jsv.salary_min >= min_salary_filter)
        AND (max_experience_filter IS NULL OR jsv.experience_required <= max_experience_filter)
        AND (job_type_filter IS NULL OR jsv.job_type = job_type_filter)
        AND (NOT remote_only_filter OR jsv.remote_option = TRUE)
    ORDER BY jsv.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

-- Users table indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_location ON users(location);
CREATE INDEX idx_users_experience ON users(experience_years);

-- Admins table indexes
CREATE INDEX idx_admins_email ON admins(email);
CREATE INDEX idx_admins_username ON admins(username);
CREATE INDEX idx_admins_company ON admins(company_name);

-- Jobs table indexes
CREATE INDEX idx_jobs_admin ON jobs(admin_id);
CREATE INDEX idx_jobs_active ON jobs(is_active);
CREATE INDEX idx_jobs_location ON jobs(job_location);
CREATE INDEX idx_jobs_type ON jobs(job_type);
CREATE INDEX idx_jobs_created ON jobs(created_at DESC);
CREATE INDEX idx_jobs_title ON jobs(job_title);

-- Job Applications indexes
CREATE INDEX idx_applications_job ON job_applications(job_id);
CREATE INDEX idx_applications_user ON job_applications(user_id);
CREATE INDEX idx_applications_status ON job_applications(application_status);
CREATE INDEX idx_applications_applied ON job_applications(applied_at DESC);

-- Skills indexes
CREATE INDEX idx_skills_name ON skills(skill_name);
CREATE INDEX idx_skills_category ON skills(category);

-- User Skills indexes
CREATE INDEX idx_user_skills_user ON user_skills(user_id);
CREATE INDEX idx_user_skills_skill ON user_skills(skill_id);

-- Job Skills indexes
CREATE INDEX idx_job_skills_job ON job_skills(job_id);
CREATE INDEX idx_job_skills_skill ON job_skills(skill_id);
CREATE INDEX idx_job_skills_required ON job_skills(is_required);

-- Job Matches indexes
CREATE INDEX idx_matches_job ON job_matches(job_id);
CREATE INDEX idx_matches_user ON job_matches(user_id);
CREATE INDEX idx_matches_score ON job_matches(match_score DESC);

-- Notifications indexes
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_admin ON notifications(admin_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);

-- ============================================
-- TRIGGERS FOR UPDATED_AT
-- ============================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_admins_updated_at BEFORE UPDATE ON admins
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_jobs_updated_at BEFORE UPDATE ON jobs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_applications_updated_at BEFORE UPDATE ON job_applications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();