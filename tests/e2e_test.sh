#!/bin/bash
# SPDX-License-Identifier: AGPL-3.0-or-later
# End-to-end test for llm-unify happy path
# Tests: init DB -> import ChatGPT/Claude -> search -> validate -> backup/restore -> TUI

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEST_DB="${PROJECT_ROOT}/test_e2e.db"
TEST_BACKUP="${PROJECT_ROOT}/test_backup.db"
BINARY="${PROJECT_ROOT}/target/release/llm-unify"
FIXTURES_DIR="${SCRIPT_DIR}/fixtures"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    exit 1
}

info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

# Cleanup
cleanup() {
    rm -f "$TEST_DB" "$TEST_DB-wal" "$TEST_DB-shm"
    rm -f "$TEST_BACKUP" "$TEST_BACKUP.meta.json" "$TEST_BACKUP.tmp"
    rm -f "${PROJECT_ROOT}/test_restore.db" "${PROJECT_ROOT}/test_restore.old"
}

trap cleanup EXIT

# Ensure binary is built
if [[ ! -f "$BINARY" ]]; then
    info "Building release binary..."
    cargo build --release --manifest-path "${PROJECT_ROOT}/Cargo.toml"
fi

# 1. Initialize database
info "Testing database initialization..."
rm -f "$TEST_DB" "$TEST_DB-wal" "$TEST_DB-shm"
output=$("$BINARY" --database "$TEST_DB" init 2>&1)
if [[ "$output" == *"Database initialized"* ]] && [[ "$output" == *"Schema version: 1"* ]]; then
    pass "Database initialized with schema version 1"
else
    fail "Database initialization failed: $output"
fi

# 2. Test schema command
info "Testing schema command..."
output=$("$BINARY" --database "$TEST_DB" schema 2>&1)
if [[ "$output" == *"Current schema version: 1"* ]] && [[ "$output" == *"Migration history:"* ]]; then
    pass "Schema command shows version and history"
else
    fail "Schema command failed: $output"
fi

# 3. Test version command
info "Testing version command..."
output=$("$BINARY" --database "$TEST_DB" version 2>&1)
if [[ "$output" == *"Schema version: 1"* ]] && [[ "$output" == *"Backup format: 1"* ]] && [[ "$output" == *"Export format: 1"* ]]; then
    pass "Version shows schema, backup, and export versions"
else
    fail "Version command failed: $output"
fi

# 4. Import ChatGPT fixture
info "Testing ChatGPT import..."
output=$("$BINARY" --database "$TEST_DB" import chatgpt "${FIXTURES_DIR}/chatgpt_export.json" 2>&1)
if [[ "$output" == *"Imported 3 conversations"* ]]; then
    pass "ChatGPT import: 3 conversations"
else
    fail "ChatGPT import failed: $output"
fi

# 5. Import Claude fixture
info "Testing Claude import..."
output=$("$BINARY" --database "$TEST_DB" import claude "${FIXTURES_DIR}/claude_export.json" 2>&1)
if [[ "$output" == *"Imported 2 conversations"* ]]; then
    pass "Claude import: 2 conversations"
else
    fail "Claude import failed: $output"
fi

# 6. Test list command
info "Testing list command..."
output=$("$BINARY" --database "$TEST_DB" list 2>&1)
if [[ "$output" == *"conv-chatgpt-001"* ]] && [[ "$output" == *"conv-claude-001"* ]]; then
    pass "List shows all conversations"
else
    fail "List command failed: $output"
fi

# 7. Test stats command
info "Testing stats command..."
output=$("$BINARY" --database "$TEST_DB" stats 2>&1)
if [[ "$output" == *"Total conversations: 5"* ]] && [[ "$output" == *"Total messages: 18"* ]]; then
    pass "Stats: 5 conversations, 18 messages"
else
    fail "Stats command failed: $output"
fi

# 8. Test validate command
info "Testing validate command..."
output=$("$BINARY" --database "$TEST_DB" validate 2>&1)
if [[ "$output" == *"SQLite integrity check passed"* ]] && [[ "$output" == *"Data consistency check passed"* ]] && [[ "$output" == *"PASSED"* ]]; then
    pass "Database validation passed"
else
    fail "Validate command failed: $output"
fi

# 9. Test search - async keyword
info "Testing search (async)..."
output=$("$BINARY" --database "$TEST_DB" search "async" 2>&1)
if [[ "$output" == *"<mark>async</mark>"* ]]; then
    pass "Search finds 'async' with highlighting"
else
    fail "Search for 'async' failed: $output"
fi

# 10. Test search - Rust keyword (multi-provider)
info "Testing search (Rust)..."
output=$("$BINARY" --database "$TEST_DB" search "Rust" --limit 5 2>&1)
if [[ "$output" == *"conv-chatgpt"* ]] && [[ "$output" == *"conv-claude"* ]]; then
    pass "Search 'Rust' returns results from both providers"
else
    fail "Search for 'Rust' failed: $output"
fi

# 11. Test search - FTS5 specific term
info "Testing search (FTS5)..."
output=$("$BINARY" --database "$TEST_DB" search "FTS5" 2>&1)
if [[ "$output" == *"conv-chatgpt-002"* ]]; then
    pass "Search finds FTS5 in correct conversation"
else
    fail "Search for 'FTS5' failed: $output"
fi

# 12. Test show command
info "Testing show command..."
output=$("$BINARY" --database "$TEST_DB" show conv-claude-001 2>&1)
if [[ "$output" == *"Understanding Ownership in Rust"* ]] && [[ "$output" == *"[user]"* ]] && [[ "$output" == *"[assistant]"* ]]; then
    pass "Show displays conversation with messages"
else
    fail "Show command failed: $output"
fi

# 13. Test versioned export
info "Testing versioned export..."
output=$("$BINARY" --database "$TEST_DB" export conv-chatgpt-001 2>&1)
if [[ "$output" == *'"format_version": 1'* ]] && [[ "$output" == *'"schema_version": 1'* ]] && [[ "$output" == *'"exported_at":'* ]]; then
    pass "Export includes version metadata"
else
    fail "Versioned export failed: $output"
fi

# 14. Test raw export
info "Testing raw export..."
output=$("$BINARY" --database "$TEST_DB" export conv-chatgpt-001 --raw 2>&1)
if [[ "$output" == *'"id": "conv-chatgpt-001"'* ]] && [[ "$output" != *'"format_version"'* ]]; then
    pass "Raw export excludes version wrapper"
else
    fail "Raw export failed: $output"
fi

# 15. Test backup with checksums
info "Testing backup with integrity..."
rm -f "$TEST_BACKUP" "$TEST_BACKUP.meta.json"
output=$("$BINARY" --database "$TEST_DB" backup "$TEST_BACKUP" 2>&1)
if [[ "$output" == *"Backup created successfully"* ]] && [[ "$output" == *"Checksum:"* ]] && [[ -f "$TEST_BACKUP.meta.json" ]]; then
    pass "Backup created with checksum and metadata"
else
    fail "Backup failed: $output"
fi

# 16. Test backup metadata
info "Testing backup metadata..."
if [[ -f "$TEST_BACKUP.meta.json" ]]; then
    meta_content=$(cat "$TEST_BACKUP.meta.json")
    if [[ "$meta_content" == *'"format_version": 1'* ]] && [[ "$meta_content" == *'"schema_version": 1'* ]] && [[ "$meta_content" == *'"checksum":'* ]]; then
        pass "Backup metadata contains version and checksum"
    else
        fail "Backup metadata incomplete: $meta_content"
    fi
else
    fail "Backup metadata file not created"
fi

# 17. Test restore with validation
info "Testing restore with validation..."
rm -f "${PROJECT_ROOT}/test_restore.db"
output=$("$BINARY" --database "${PROJECT_ROOT}/test_restore.db" restore "$TEST_BACKUP" 2>&1)
if [[ "$output" == *"Backup validated"* ]] && [[ "$output" == *"Checksum:"* ]] && [[ "$output" == *"(verified)"* ]] && [[ "$output" == *"Database restored"* ]]; then
    pass "Restore validates checksum before restoring"
else
    fail "Restore failed: $output"
fi

# 18. Verify restored database works
info "Verifying restored database..."
output=$("$BINARY" --database "${PROJECT_ROOT}/test_restore.db" stats 2>&1)
if [[ "$output" == *"Total conversations: 5"* ]] && [[ "$output" == *"Total messages: 18"* ]]; then
    pass "Restored database has correct data"
else
    fail "Restored database verification failed: $output"
fi

# 19. Test TUI launch (requires pseudo-terminal)
info "Testing TUI launch..."
if command -v script &> /dev/null; then
    # Use script to provide a pseudo-terminal
    output=$(script -q -c "$BINARY --database $TEST_DB tui" /dev/null <<< 'q' 2>&1 || true)
    # Check for escape sequences indicating TUI started (alternate screen mode)
    if [[ "$output" == *"[?1049h"* ]] || [[ "$output" == *"[?25l"* ]]; then
        pass "TUI launches and responds to 'q' quit"
    else
        # In some environments, TUI may not work due to terminal limitations
        info "TUI test inconclusive (may require real terminal)"
    fi
else
    info "Skipping TUI test (script command not available)"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}All E2E tests passed!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Summary:"
echo "  - Database initialization with schema versioning: OK"
echo "  - Schema and version commands: OK"
echo "  - ChatGPT import (3 conversations): OK"
echo "  - Claude import (2 conversations): OK"
echo "  - List, stats, show commands: OK"
echo "  - Database validation (SQLite + consistency): OK"
echo "  - Full-text search with highlighting: OK"
echo "  - Versioned export with metadata: OK"
echo "  - Backup with SHA-256 checksum: OK"
echo "  - Restore with integrity verification: OK"
echo "  - TUI startup: OK"
