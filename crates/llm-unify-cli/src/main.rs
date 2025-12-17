// SPDX-License-Identifier: AGPL-3.0-or-later
//! LLM Unify CLI

use anyhow::Result;
use clap::{Parser, Subcommand};
use llm_unify_core::Provider;
use llm_unify_parser::get_parser;
use llm_unify_search::SearchEngine;
use llm_unify_storage::{ConversationRepository, Database};
use std::path::PathBuf;

#[derive(Parser)]
#[command(name = "llm-unify")]
#[command(about = "Unified interface for managing LLM conversations", long_about = None)]
#[command(version)]
struct Cli {
    #[command(subcommand)]
    command: Commands,

    /// Database file path
    #[arg(short, long, default_value = "llm-unify.db")]
    database: PathBuf,
}

#[derive(Subcommand)]
enum Commands {
    /// Import conversations from a provider
    Import {
        /// Provider name (chatgpt, claude, gemini, copilot)
        provider: String,

        /// Path to export file
        file: PathBuf,
    },

    /// List all conversations
    List {
        /// Filter by provider
        #[arg(short, long)]
        provider: Option<String>,
    },

    /// Show a conversation
    Show {
        /// Conversation ID
        id: String,
    },

    /// Search conversations
    Search {
        /// Search query
        query: String,

        /// Limit results
        #[arg(short, long, default_value = "10")]
        limit: usize,
    },

    /// Delete a conversation
    Delete {
        /// Conversation ID
        id: String,
    },

    /// Export a conversation
    Export {
        /// Conversation ID
        id: String,

        /// Output file
        #[arg(short, long)]
        output: Option<PathBuf>,
    },

    /// Show statistics
    Stats,

    /// Validate database integrity
    Validate,

    /// Backup database
    Backup {
        /// Backup file path
        output: PathBuf,
    },

    /// Restore from backup
    Restore {
        /// Backup file path
        input: PathBuf,
    },

    /// Initialize database
    Init,

    /// Launch TUI
    Tui,

    /// Show version information
    Version,
}

#[tokio::main]
async fn main() -> Result<()> {
    let cli = Cli::parse();

    let db = Database::new(&cli.database).await?;

    match cli.command {
        Commands::Import { provider, file } => {
            let provider_enum = parse_provider(&provider)?;
            let parser = get_parser(provider_enum);

            let data = std::fs::read(&file)?;
            let conversations = parser.parse(&data)?;
            let count = conversations.len();

            let repo = ConversationRepository::new(&db);
            for conv in conversations {
                repo.save(&conv).await?;
            }

            println!("Imported {} conversations from {}", count, provider);
        }

        Commands::List { provider } => {
            let repo = ConversationRepository::new(&db);
            let conversations = repo.list().await?;

            let filtered: Vec<_> = if let Some(p) = provider {
                let provider_enum = parse_provider(&p)?;
                conversations
                    .into_iter()
                    .filter(|c| c.provider == provider_enum)
                    .collect()
            } else {
                conversations
            };

            for conv in filtered {
                println!(
                    "{} | {} | {} | {} messages",
                    conv.id,
                    conv.provider,
                    conv.title,
                    conv.message_count()
                );
            }
        }

        Commands::Show { id } => {
            let repo = ConversationRepository::new(&db);
            if let Some(conv) = repo.find_by_id(&id).await? {
                println!("Conversation: {}", conv.title);
                println!("Provider: {}", conv.provider);
                println!("Messages: {}", conv.message_count());
                println!();

                for msg in conv.messages {
                    println!("[{}] {}", msg.role, msg.content);
                    println!();
                }
            } else {
                println!("Conversation not found");
            }
        }

        Commands::Search { query, limit } => {
            let search = SearchEngine::new(&db);
            let results = search.search(&query).await?;

            for (i, result) in results.iter().take(limit).enumerate() {
                println!("{}. Conversation: {}", i + 1, result.conversation_id);
                println!("   {}", result.snippet);
                println!();
            }
        }

        Commands::Delete { id } => {
            let repo = ConversationRepository::new(&db);
            repo.delete(&id).await?;
            println!("Deleted conversation: {}", id);
        }

        Commands::Export { id, output } => {
            let repo = ConversationRepository::new(&db);
            if let Some(conv) = repo.find_by_id(&id).await? {
                let json = serde_json::to_string_pretty(&conv)?;

                if let Some(path) = output {
                    std::fs::write(&path, json)?;
                    println!("Exported to: {}", path.display());
                } else {
                    println!("{}", json);
                }
            } else {
                println!("Conversation not found");
            }
        }

        Commands::Stats => {
            let repo = ConversationRepository::new(&db);
            let conversations = repo.list().await?;

            let total_convs = conversations.len();
            let total_msgs: usize = conversations.iter().map(|c| c.message_count()).sum();

            println!("Total conversations: {}", total_convs);
            println!("Total messages: {}", total_msgs);

            // Count by provider
            let mut provider_counts = std::collections::HashMap::new();
            for conv in conversations {
                *provider_counts.entry(conv.provider).or_insert(0) += 1;
            }

            println!("\nBy provider:");
            for (provider, count) in provider_counts {
                println!("  {}: {}", provider, count);
            }
        }

        Commands::Validate => {
            println!("Database validation not yet implemented");
        }

        Commands::Backup { output } => {
            std::fs::copy(&cli.database, &output)?;
            println!("Backup created: {}", output.display());
        }

        Commands::Restore { input } => {
            std::fs::copy(&input, &cli.database)?;
            println!("Database restored from: {}", input.display());
        }

        Commands::Init => {
            println!("Database initialized: {}", cli.database.display());
        }

        Commands::Tui => {
            llm_unify_tui::run(db).await?;
        }

        Commands::Version => {
            println!("llm-unify v{}", env!("CARGO_PKG_VERSION"));
        }
    }

    Ok(())
}

fn parse_provider(s: &str) -> Result<Provider> {
    match s.to_lowercase().as_str() {
        "chatgpt" => Ok(Provider::ChatGpt),
        "claude" => Ok(Provider::Claude),
        "gemini" => Ok(Provider::Gemini),
        "copilot" => Ok(Provider::Copilot),
        _ => Err(anyhow::anyhow!("Unknown provider: {}", s)),
    }
}
