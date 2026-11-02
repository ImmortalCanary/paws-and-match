-- psql-Treiberskript. Nur auf einer leeren separaten Projektdatenbank ausfuehren.
\set ON_ERROR_STOP on
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' AND c.relkind IN ('r','p','v','m','S')) THEN
        RAISE EXCEPTION 'Gesamtaufbau benoetigt ein leeres public-Schema; keine vorhandenen Tabellen ueberschreiben';
    END IF;
END $$;
\ir 001_schema.sql
\ir 002_demo_data.sql
\ir tests/001_tests.sql
\ir 003_matching.sql
\ir 004_auswertungen.sql
\ir 005_bewerbung_demo.sql
\ir migrations/006_matching_v2.sql
\ir tests/002_matching_v2.sql
\ir migrations/007_medizinische_merkmale.sql
\ir tests/003_medizinische_merkmale.sql
\ir seeds/008_erweiterte_demo.sql
\ir tests/004_erweiterte_demo.sql
\ir migrations/010_organisationen.sql
\ir seeds/011_organisationen_demo.sql
\ir tests/005_organisationen.sql
\ir tests/004_erweiterte_demo.sql
\ir 009_standort_matching.sql
SELECT * FROM standort_uebersicht ORDER BY tierheim_id;
