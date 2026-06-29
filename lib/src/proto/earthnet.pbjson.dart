// This is a generated file - do not edit.
//
// Generated from earthnet.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use sourceTypeDescriptor instead')
const SourceType$json = {
  '1': 'SourceType',
  '2': [
    {'1': 'SOURCE_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'SOURCE_TYPE_OFFICIAL', '2': 1},
    {'1': 'SOURCE_TYPE_PHONE', '2': 2},
  ],
};

/// Descriptor for `SourceType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List sourceTypeDescriptor = $convert.base64Decode(
    'CgpTb3VyY2VUeXBlEhsKF1NPVVJDRV9UWVBFX1VOU1BFQ0lGSUVEEAASGAoUU09VUkNFX1RZUE'
    'VfT0ZGSUNJQUwQARIVChFTT1VSQ0VfVFlQRV9QSE9ORRAC');

@$core.Deprecated('Use evidenceKindDescriptor instead')
const EvidenceKind$json = {
  '1': 'EvidenceKind',
  '2': [
    {'1': 'EVIDENCE_KIND_UNSPECIFIED', '2': 0},
    {'1': 'EVIDENCE_KIND_OFFICIAL', '2': 1},
    {'1': 'EVIDENCE_KIND_CONSENSUS', '2': 2},
    {'1': 'EVIDENCE_KIND_BOTH', '2': 3},
  ],
};

/// Descriptor for `EvidenceKind`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List evidenceKindDescriptor = $convert.base64Decode(
    'CgxFdmlkZW5jZUtpbmQSHQoZRVZJREVOQ0VfS0lORF9VTlNQRUNJRklFRBAAEhoKFkVWSURFTk'
    'NFX0tJTkRfT0ZGSUNJQUwQARIbChdFVklERU5DRV9LSU5EX0NPTlNFTlNVUxACEhYKEkVWSURF'
    'TkNFX0tJTkRfQk9USBAD');

@$core.Deprecated('Use locationDescriptor instead')
const Location$json = {
  '1': 'Location',
  '2': [
    {'1': 'geohash', '3': 1, '4': 1, '5': 9, '10': 'geohash'},
    {'1': 'precision_m', '3': 2, '4': 1, '5': 13, '10': 'precisionM'},
  ],
};

/// Descriptor for `Location`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List locationDescriptor = $convert.base64Decode(
    'CghMb2NhdGlvbhIYCgdnZW9oYXNoGAEgASgJUgdnZW9oYXNoEh8KC3ByZWNpc2lvbl9tGAIgAS'
    'gNUgpwcmVjaXNpb25N');

@$core.Deprecated('Use observationDescriptor instead')
const Observation$json = {
  '1': 'Observation',
  '2': [
    {'1': 'protocol_version', '3': 1, '4': 1, '5': 13, '10': 'protocolVersion'},
    {'1': 'observation_id', '3': 2, '4': 1, '5': 12, '10': 'observationId'},
    {'1': 'pubkey', '3': 3, '4': 1, '5': 12, '10': 'pubkey'},
    {
      '1': 'source_type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.earthnet.v1.SourceType',
      '10': 'sourceType'
    },
    {'1': 'source_id', '3': 5, '4': 1, '5': 9, '10': 'sourceId'},
    {'1': 'captured_at_ns', '3': 6, '4': 1, '5': 3, '10': 'capturedAtNs'},
    {'1': 'clock_uncert_ms', '3': 7, '4': 1, '5': 13, '10': 'clockUncertMs'},
    {
      '1': 'location',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.earthnet.v1.Location',
      '10': 'location'
    },
    {'1': 'sta_lta_ratio', '3': 9, '4': 1, '5': 2, '10': 'staLtaRatio'},
    {'1': 'p_wave_detected', '3': 10, '4': 1, '5': 8, '10': 'pWaveDetected'},
    {'1': 'estimated_pga', '3': 11, '4': 1, '5': 2, '10': 'estimatedPga'},
    {
      '1': 'reported_magnitude',
      '3': 12,
      '4': 1,
      '5': 2,
      '10': 'reportedMagnitude'
    },
    {'1': 'signature', '3': 15, '4': 1, '5': 12, '10': 'signature'},
  ],
};

/// Descriptor for `Observation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List observationDescriptor = $convert.base64Decode(
    'CgtPYnNlcnZhdGlvbhIpChBwcm90b2NvbF92ZXJzaW9uGAEgASgNUg9wcm90b2NvbFZlcnNpb2'
    '4SJQoOb2JzZXJ2YXRpb25faWQYAiABKAxSDW9ic2VydmF0aW9uSWQSFgoGcHVia2V5GAMgASgM'
    'UgZwdWJrZXkSOAoLc291cmNlX3R5cGUYBCABKA4yFy5lYXJ0aG5ldC52MS5Tb3VyY2VUeXBlUg'
    'pzb3VyY2VUeXBlEhsKCXNvdXJjZV9pZBgFIAEoCVIIc291cmNlSWQSJAoOY2FwdHVyZWRfYXRf'
    'bnMYBiABKANSDGNhcHR1cmVkQXROcxImCg9jbG9ja191bmNlcnRfbXMYByABKA1SDWNsb2NrVW'
    '5jZXJ0TXMSMQoIbG9jYXRpb24YCCABKAsyFS5lYXJ0aG5ldC52MS5Mb2NhdGlvblIIbG9jYXRp'
    'b24SIgoNc3RhX2x0YV9yYXRpbxgJIAEoAlILc3RhTHRhUmF0aW8SJgoPcF93YXZlX2RldGVjdG'
    'VkGAogASgIUg1wV2F2ZURldGVjdGVkEiMKDWVzdGltYXRlZF9wZ2EYCyABKAJSDGVzdGltYXRl'
    'ZFBnYRItChJyZXBvcnRlZF9tYWduaXR1ZGUYDCABKAJSEXJlcG9ydGVkTWFnbml0dWRlEhwKCX'
    'NpZ25hdHVyZRgPIAEoDFIJc2lnbmF0dXJl');

@$core.Deprecated('Use confirmedEventDescriptor instead')
const ConfirmedEvent$json = {
  '1': 'ConfirmedEvent',
  '2': [
    {'1': 'protocol_version', '3': 1, '4': 1, '5': 13, '10': 'protocolVersion'},
    {'1': 'event_id', '3': 2, '4': 1, '5': 12, '10': 'eventId'},
    {'1': 'pubkey', '3': 3, '4': 1, '5': 12, '10': 'pubkey'},
    {'1': 'origin_time_ns', '3': 4, '4': 1, '5': 3, '10': 'originTimeNs'},
    {'1': 'issued_at_ns', '3': 5, '4': 1, '5': 3, '10': 'issuedAtNs'},
    {
      '1': 'epicenter',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.earthnet.v1.Location',
      '10': 'epicenter'
    },
    {'1': 'depth_km', '3': 7, '4': 1, '5': 2, '10': 'depthKm'},
    {'1': 'magnitude', '3': 8, '4': 1, '5': 2, '10': 'magnitude'},
    {'1': 'magnitude_uncert', '3': 9, '4': 1, '5': 2, '10': 'magnitudeUncert'},
    {
      '1': 'evidence',
      '3': 10,
      '4': 1,
      '5': 14,
      '6': '.earthnet.v1.EvidenceKind',
      '10': 'evidence'
    },
    {
      '1': 'num_observations',
      '3': 11,
      '4': 1,
      '5': 13,
      '10': 'numObservations'
    },
    {'1': 'obs_ids', '3': 12, '4': 3, '5': 12, '10': 'obsIds'},
    {'1': 'supersedes', '3': 13, '4': 1, '5': 12, '10': 'supersedes'},
    {'1': 'signature', '3': 15, '4': 1, '5': 12, '10': 'signature'},
  ],
};

/// Descriptor for `ConfirmedEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List confirmedEventDescriptor = $convert.base64Decode(
    'Cg5Db25maXJtZWRFdmVudBIpChBwcm90b2NvbF92ZXJzaW9uGAEgASgNUg9wcm90b2NvbFZlcn'
    'Npb24SGQoIZXZlbnRfaWQYAiABKAxSB2V2ZW50SWQSFgoGcHVia2V5GAMgASgMUgZwdWJrZXkS'
    'JAoOb3JpZ2luX3RpbWVfbnMYBCABKANSDG9yaWdpblRpbWVOcxIgCgxpc3N1ZWRfYXRfbnMYBS'
    'ABKANSCmlzc3VlZEF0TnMSMwoJZXBpY2VudGVyGAYgASgLMhUuZWFydGhuZXQudjEuTG9jYXRp'
    'b25SCWVwaWNlbnRlchIZCghkZXB0aF9rbRgHIAEoAlIHZGVwdGhLbRIcCgltYWduaXR1ZGUYCC'
    'ABKAJSCW1hZ25pdHVkZRIpChBtYWduaXR1ZGVfdW5jZXJ0GAkgASgCUg9tYWduaXR1ZGVVbmNl'
    'cnQSNQoIZXZpZGVuY2UYCiABKA4yGS5lYXJ0aG5ldC52MS5FdmlkZW5jZUtpbmRSCGV2aWRlbm'
    'NlEikKEG51bV9vYnNlcnZhdGlvbnMYCyABKA1SD251bU9ic2VydmF0aW9ucxIXCgdvYnNfaWRz'
    'GAwgAygMUgZvYnNJZHMSHgoKc3VwZXJzZWRlcxgNIAEoDFIKc3VwZXJzZWRlcxIcCglzaWduYX'
    'R1cmUYDyABKAxSCXNpZ25hdHVyZQ==');
