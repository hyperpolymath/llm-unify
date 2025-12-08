;; STATE.scm - LLM Unify Project State Checkpoint
;; Format: S-expression (Scheme) for minimal, readable syntax
;; Usage: Download at session end, upload at session start
;; Repository: https://github.com/hyperpolymath/llm-unify

(define state
  '(

    ;; ═══════════════════════════════════════════════════════════════════════
    ;; METADATA
    ;; ═══════════════════════════════════════════════════════════════════════
    (metadata
      (format-version . "2.0")
      (schema-version . "2025-12-08")
      (created . "2025-12-08T00:00:00Z")
      (last-updated . "2025-12-08T00:00:00Z")
      (generator . "claude-opus-4"))

    ;; ═══════════════════════════════════════════════════════════════════════
    ;; CURRENT POSITION
    ;; ═══════════════════════════════════════════════════════════════════════
    (current-position
      (version . "0.1.0")
      (phase . "post-mvp-foundation")
      (compliance . "RSR-Silver-51/55")
      (summary . "Solid foundation with ChatGPT import working. Three parsers stubbed, TUI incomplete, tests sparse.")

      (working-features
        "ChatGPT JSON export parsing (fully functional)"
        "SQLite persistence with normalized schema"
        "Full-text search via FTS5"
        "CLI with 13 commands"
        "Basic TUI with conversation browser"
        "Backup/restore functionality"
        "RFC 9116 security.txt compliance"
        "Zero unsafe code blocks")

      (incomplete-features
        "Claude parser (stub only)"
        "Gemini parser (stub only)"
        "Copilot parser (stub only)"
        "TUI message viewing (select/expand not implemented)"
        "TUI search execution (captures input, doesn't query)"
        "Database validation command (prints 'not yet implemented')"
        "Test coverage (30% vs 80% target)"))

    ;; ═══════════════════════════════════════════════════════════════════════
    ;; ROUTE TO MVP v1.0
    ;; ═══════════════════════════════════════════════════════════════════════
    (mvp-roadmap
      (target-version . "1.0.0")
      (definition . "All 4 parsers functional, CLI complete, TUI usable, 70%+ tests, published to crates.io")

      (phase-1
        (name . "core-completion")
        (status . "pending")
        (tasks
          (task
            (id . "parser-claude")
            (name . "Implement Claude parser")
            (file . "crates/llm-unify-parser/src/claude.rs")
            (effort . "100-150 LOC")
            (status . "pending")
            (notes . "Follow ChatGPT parser pattern. Need Claude export format samples."))
          (task
            (id . "parser-gemini")
            (name . "Implement Gemini parser")
            (file . "crates/llm-unify-parser/src/gemini.rs")
            (effort . "100-150 LOC")
            (status . "pending")
            (notes . "Need Gemini export format documentation."))
          (task
            (id . "parser-copilot")
            (name . "Implement Copilot parser")
            (file . "crates/llm-unify-parser/src/copilot.rs")
            (effort . "100-150 LOC")
            (status . "pending")
            (notes . "GitHub Copilot chat export format TBD."))
          (task
            (id . "tui-message-view")
            (name . "Implement TUI message viewing")
            (file . "crates/llm-unify-tui/src/lib.rs")
            (effort . "200-300 LOC")
            (status . "pending")
            (notes . "Press Enter to expand conversation, show messages with pagination."))
          (task
            (id . "tui-search")
            (name . "Implement TUI search execution")
            (file . "crates/llm-unify-tui/src/lib.rs")
            (effort . "100-150 LOC")
            (status . "pending")
            (notes . "Execute FTS5 queries from search bar, display results."))
          (task
            (id . "db-validate")
            (name . "Implement database validation")
            (file . "crates/llm-unify-cli/src/main.rs")
            (effort . "50-100 LOC")
            (status . "pending")
            (notes . "Schema integrity checks, constraint validation."))))

      (phase-2
        (name . "testing-quality")
        (status . "pending")
        (tasks
          (task
            (id . "tests-parsers")
            (name . "Add parser unit tests")
            (effort . "~200 LOC per parser")
            (status . "pending"))
          (task
            (id . "tests-storage")
            (name . "Add storage integration tests")
            (effort . "~150 LOC")
            (status . "pending"))
          (task
            (id . "tests-search")
            (name . "Add search engine tests")
            (effort . "~100 LOC")
            (status . "pending"))
          (task
            (id . "tests-tui")
            (name . "Add TUI state management tests")
            (effort . "~100 LOC")
            (status . "pending"))))

      (phase-3
        (name . "security-release")
        (status . "pending")
        (tasks
          (task
            (id . "security-audit")
            (name . "Internal security audit")
            (status . "pending"))
          (task
            (id . "perf-testing")
            (name . "Performance testing with large datasets")
            (status . "pending"))
          (task
            (id . "crates-io")
            (name . "Publish to crates.io")
            (status . "pending")))))

    ;; ═══════════════════════════════════════════════════════════════════════
    ;; ISSUES / BLOCKERS
    ;; ═══════════════════════════════════════════════════════════════════════
    (blockers
      (blocker
        (id . "export-formats")
        (severity . "high")
        (description . "Need export format documentation/samples for Claude, Gemini, Copilot")
        (impact . "Cannot implement parsers without knowing the JSON structure")
        (resolution . "Obtain export samples from each platform, document format"))

      (blocker
        (id . "test-coverage")
        (severity . "medium")
        (description . "Test coverage at 30%, target is 80% for production")
        (impact . "Risk of regressions, cannot achieve RSR Gold compliance")
        (resolution . "Write comprehensive test suites for all crates"))

      (blocker
        (id . "tui-architecture")
        (severity . "low")
        (description . "TUI state management needs refinement for message viewing")
        (impact . "User experience limited to list view only")
        (resolution . "Implement state machine for view transitions")))

    ;; ═══════════════════════════════════════════════════════════════════════
    ;; QUESTIONS FOR USER
    ;; ═══════════════════════════════════════════════════════════════════════
    (questions
      (question
        (id . "q1")
        (priority . "high")
        (topic . "Export Format Samples")
        (question . "Can you provide sample export files from Claude, Gemini, and Copilot?")
        (context . "Needed to implement the remaining parsers. ChatGPT parser is complete and can serve as template."))

      (question
        (id . "q2")
        (priority . "medium")
        (topic . "MVP Feature Scope")
        (question . "Is TUI mandatory for MVP v1.0, or can we ship CLI-only first?")
        (context . "TUI requires significant work. CLI is fully functional."))

      (question
        (id . "q3")
        (priority . "medium")
        (topic . "Parser Priority")
        (question . "Which parser should be prioritized: Claude, Gemini, or Copilot?")
        (context . "If samples are available for only one platform, we can focus there first."))

      (question
        (id . "q4")
        (priority . "low")
        (topic . "Encryption Timeline")
        (question . "Is database encryption (SQLCipher) needed for v1.0 or can it wait for v1.1?")
        (context . "Currently marked as v0.2 feature. Adds complexity but improves security."))

      (question
        (id . "q5")
        (priority . "low")
        (topic . "CI/CD Platform")
        (question . "Should we prioritize GitHub Actions or GitLab CI for the main pipeline?")
        (context . "Both configs exist. Need to decide primary platform.")))

    ;; ═══════════════════════════════════════════════════════════════════════
    ;; LONG-TERM ROADMAP
    ;; ═══════════════════════════════════════════════════════════════════════
    (roadmap
      (v1.0
        (name . "MVP Release")
        (status . "in-progress")
        (completion . 40)
        (goals
          "All 4 parsers functional"
          "CLI feature-complete"
          "TUI usable (browse, search, view)"
          "70%+ test coverage"
          "Published to crates.io"))

      (v1.1
        (name . "Security Hardening")
        (status . "planned")
        (goals
          "External security audit"
          "Database encryption (SQLCipher)"
          "Export encryption"
          "80%+ test coverage"
          "RSR Gold compliance"))

      (v1.2
        (name . "Platform Expansion")
        (status . "planned")
        (goals
          "Additional LLM platform parsers (Perplexity, Mistral, etc.)"
          "Export to multiple formats (JSON, Markdown, PDF)"
          "Conversation tagging and organization"
          "Advanced search filters"))

      (v2.0
        (name . "Ecosystem Integration")
        (status . "future")
        (goals
          "API server mode (REST/GraphQL)"
          "Plugin system for custom parsers"
          "Sync across devices (optional, encrypted)"
          "Web UI alternative"
          "Conversation analytics and insights"))

      (v3.0
        (name . "Intelligence Layer")
        (status . "future")
        (goals
          "Local LLM integration for summarization"
          "Semantic search (vector embeddings)"
          "Conversation clustering"
          "Knowledge graph extraction"
          "Cross-conversation insights")))

    ;; ═══════════════════════════════════════════════════════════════════════
    ;; ARCHITECTURE NOTES
    ;; ═══════════════════════════════════════════════════════════════════════
    (architecture
      (workspace-structure
        ("llm-unify-core" . "Domain models, Provider trait")
        ("llm-unify-storage" . "SQLite persistence, repositories")
        ("llm-unify-parser" . "Import parsers per platform")
        ("llm-unify-search" . "FTS5 search engine")
        ("llm-unify-cli" . "13 CLI commands via clap")
        ("llm-unify-tui" . "Ratatui terminal UI"))

      (key-files
        ("crates/llm-unify-core/src/models.rs" . "Conversation, Message, Provider enums")
        ("crates/llm-unify-storage/src/database.rs" . "Schema, init, migrations")
        ("crates/llm-unify-parser/src/chatgpt.rs" . "Reference parser implementation")
        ("crates/llm-unify-search/src/search.rs" . "FTS5 query builder")
        ("crates/llm-unify-cli/src/main.rs" . "CLI entry point")
        ("crates/llm-unify-tui/src/lib.rs" . "TUI app state and render"))

      (dependencies
        ("tokio" . "Async runtime")
        ("sqlx" . "Type-safe SQL")
        ("ratatui" . "TUI framework")
        ("clap" . "CLI parser")
        ("serde" . "Serialization")))

    ;; ═══════════════════════════════════════════════════════════════════════
    ;; CRITICAL NEXT ACTIONS
    ;; ═══════════════════════════════════════════════════════════════════════
    (critical-next-actions
      (action
        (priority . 1)
        (description . "Obtain Claude/Gemini/Copilot export samples")
        (rationale . "Blocks all parser implementation"))
      (action
        (priority . 2)
        (description . "Implement Claude parser (highest demand)")
        (rationale . "Claude users are likely early adopters"))
      (action
        (priority . 3)
        (description . "Add TUI message viewing")
        (rationale . "Core UX gap - users can't read conversations"))
      (action
        (priority . 4)
        (description . "Write parser unit tests")
        (rationale . "Test coverage critical for reliability"))
      (action
        (priority . 5)
        (description . "Document export format specifications")
        (rationale . "Enable community contributions")))

    ;; ═══════════════════════════════════════════════════════════════════════
    ;; HISTORY SNAPSHOTS (for velocity tracking)
    ;; ═══════════════════════════════════════════════════════════════════════
    (history
      (snapshot
        (date . "2025-12-08")
        (version . "0.1.0")
        (overall-completion . 40)
        (notes . "Initial STATE.scm creation. Foundation complete, parsers pending.")))

    ;; ═══════════════════════════════════════════════════════════════════════
    ;; SESSION FILES
    ;; ═══════════════════════════════════════════════════════════════════════
    (session-files
      (created
        "STATE.scm")
      (modified))

)) ;; end state

;; ═══════════════════════════════════════════════════════════════════════════
;; QUICK REFERENCE
;; ═══════════════════════════════════════════════════════════════════════════
;;
;; To resume work:
;;   1. Upload this file at session start
;;   2. Claude will parse and restore full context
;;   3. Continue from critical-next-actions
;;
;; To save progress:
;;   1. Update completion percentages
;;   2. Add new tasks/blockers discovered
;;   3. Move completed items to history
;;   4. Download updated STATE.scm
;;
;; Key commands:
;;   cargo build --workspace     # Build all crates
;;   just test                   # Run test suite
;;   just lint                   # Run clippy
;;   just compliance             # Check RSR compliance
;;
;; ═══════════════════════════════════════════════════════════════════════════
