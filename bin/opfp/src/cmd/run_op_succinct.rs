//! Run OP Succinct Subcommand

use std::fs::File;

use clap::Parser;
use color_eyre::{eyre::eyre, Result};
use op_succinct_client_utils::boot::BootInfoStruct;
use op_succinct_host_utils::RANGE_ELF_BUMP;
use serde::{Deserialize, Serialize};
use sp1_core_executor::syscalls::SyscallCode;
use sp1_sdk::ProverClient;

use crate::cmd::run_op_program::ProgramStats;

use super::run_common::RunCommon;

/// CLI arguments for the `run-op-succinct` subcommand of `opfp`.
#[derive(Parser, Clone, Debug)]
pub struct RunOpSuccinct {
    /// Common arguments.
    #[clap(flatten)]
    pub common: RunCommon,
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct OpSuccinctStats {
    pub runtime: u128,
    pub total_instruction_count: u64,
    pub oracle_verify_instruction_count: u64,
    pub blob_verification_instruction_count: u64,
    pub payload_derivation_instruction_count: u64,
    pub block_execution_instruction_count: u64,
    pub serialization_instruction_count: u64,
    pub keccak_syscall_count: u64,
    pub memory_used: usize,
    pub sp1_gas: u64,
}

impl RunOpSuccinct {
    /// Runs the `run-op-succinct` subcommand.
    pub async fn run(&self) -> Result<()> {
        let prover = ProverClient::builder().cpu().build();

        let file = File::open(&self.common.fixture)?;
        let stdin = serde_json::from_reader(file)?;
        let start = std::time::Instant::now();

        let (mut public_values, execution_report) = prover
            .execute(RANGE_ELF_BUMP, &stdin)
            .run()
            .map_err(|err| eyre!("{err}"))?;

        let runtime = start.elapsed().as_millis();
        let get_cycles = |key: &str| *execution_report.cycle_tracker.get(key).unwrap_or(&0);

        let _ = public_values.read::<BootInfoStruct>();
        let memory_used = public_values.read::<usize>();

        println!("{execution_report}");

        let stats = OpSuccinctStats {
            runtime,
            total_instruction_count: execution_report.total_instruction_count(),
            oracle_verify_instruction_count: get_cycles("oracle-verify"),
            blob_verification_instruction_count: get_cycles("blob-verification"),
            payload_derivation_instruction_count: get_cycles("payload-derivation"),
            block_execution_instruction_count: get_cycles("block-execution"),
            serialization_instruction_count: get_cycles(
                "in-memory-oracle-from-raw-bytes-deserialize",
            ),
            keccak_syscall_count: execution_report.syscall_counts[SyscallCode::KECCAK_PERMUTE],
            memory_used,
            sp1_gas: execution_report.gas.unwrap_or_default(),
        };

        if let Some(output) = &self.common.output {
            let file = std::fs::File::create(output)?;
            serde_json::to_writer_pretty(file, &stats)?;
        }

        Ok(())
    }
}
