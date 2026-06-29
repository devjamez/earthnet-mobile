//! Bridge to the shared Rust P-wave detector (earthnet_protocol::detect).
//!
//! The phone becomes a sensor (DESIGN v1.1): it runs the SAME deterministic
//! STA/LTA detection the node/adapters run — no reimplementation, no ML in the
//! alert path. Feed it a rolling window of one accelerometer channel.

/// A detected P-wave onset.
pub struct DetectedPick {
    /// Sample index of the onset within the supplied window.
    pub index: u64,
    /// STA/LTA ratio at the onset.
    pub sta_lta_ratio: f64,
}

/// Run STA/LTA detection over one channel. Returns the first pick, or null.
/// `sampling_rate` in Hz; needs > LTA_SECONDS of data.
#[flutter_rust_bridge::frb(sync)]
pub fn detect_pick(samples: Vec<f64>, sampling_rate: f64) -> Option<DetectedPick> {
    earthnet_protocol::detect::detect_pick(&samples, sampling_rate).map(|p| DetectedPick {
        index: p.index as u64,
        sta_lta_ratio: p.sta_lta_ratio,
    })
}

/// STA/LTA trigger threshold the detector uses (for UI display).
#[flutter_rust_bridge::frb(sync)]
pub fn trigger_on() -> f64 {
    earthnet_protocol::detect::TRIGGER_ON
}
