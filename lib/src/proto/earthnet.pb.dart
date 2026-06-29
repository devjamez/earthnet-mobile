// This is a generated file - do not edit.
//
// Generated from earthnet.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'earthnet.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'earthnet.pbenum.dart';

class Location extends $pb.GeneratedMessage {
  factory Location({
    $core.String? geohash,
    $core.int? precisionM,
  }) {
    final result = create();
    if (geohash != null) result.geohash = geohash;
    if (precisionM != null) result.precisionM = precisionM;
    return result;
  }

  Location._();

  factory Location.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Location.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Location',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'earthnet.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'geohash')
    ..aI(2, _omitFieldNames ? '' : 'precisionM', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Location clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Location copyWith(void Function(Location) updates) =>
      super.copyWith((message) => updates(message as Location)) as Location;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Location create() => Location._();
  @$core.override
  Location createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Location getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Location>(create);
  static Location? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get geohash => $_getSZ(0);
  @$pb.TagNumber(1)
  set geohash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasGeohash() => $_has(0);
  @$pb.TagNumber(1)
  void clearGeohash() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get precisionM => $_getIZ(1);
  @$pb.TagNumber(2)
  set precisionM($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPrecisionM() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrecisionM() => $_clearField(2);
}

class Observation extends $pb.GeneratedMessage {
  factory Observation({
    $core.int? protocolVersion,
    $core.List<$core.int>? observationId,
    $core.List<$core.int>? pubkey,
    SourceType? sourceType,
    $core.String? sourceId,
    $fixnum.Int64? capturedAtNs,
    $core.int? clockUncertMs,
    Location? location,
    $core.double? staLtaRatio,
    $core.bool? pWaveDetected,
    $core.double? estimatedPga,
    $core.double? reportedMagnitude,
    $core.List<$core.int>? signature,
  }) {
    final result = create();
    if (protocolVersion != null) result.protocolVersion = protocolVersion;
    if (observationId != null) result.observationId = observationId;
    if (pubkey != null) result.pubkey = pubkey;
    if (sourceType != null) result.sourceType = sourceType;
    if (sourceId != null) result.sourceId = sourceId;
    if (capturedAtNs != null) result.capturedAtNs = capturedAtNs;
    if (clockUncertMs != null) result.clockUncertMs = clockUncertMs;
    if (location != null) result.location = location;
    if (staLtaRatio != null) result.staLtaRatio = staLtaRatio;
    if (pWaveDetected != null) result.pWaveDetected = pWaveDetected;
    if (estimatedPga != null) result.estimatedPga = estimatedPga;
    if (reportedMagnitude != null) result.reportedMagnitude = reportedMagnitude;
    if (signature != null) result.signature = signature;
    return result;
  }

  Observation._();

  factory Observation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Observation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Observation',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'earthnet.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'protocolVersion',
        fieldType: $pb.PbFieldType.OU3)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'observationId', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'pubkey', $pb.PbFieldType.OY)
    ..aE<SourceType>(4, _omitFieldNames ? '' : 'sourceType',
        enumValues: SourceType.values)
    ..aOS(5, _omitFieldNames ? '' : 'sourceId')
    ..aInt64(6, _omitFieldNames ? '' : 'capturedAtNs')
    ..aI(7, _omitFieldNames ? '' : 'clockUncertMs',
        fieldType: $pb.PbFieldType.OU3)
    ..aOM<Location>(8, _omitFieldNames ? '' : 'location',
        subBuilder: Location.create)
    ..aD(9, _omitFieldNames ? '' : 'staLtaRatio', fieldType: $pb.PbFieldType.OF)
    ..aOB(10, _omitFieldNames ? '' : 'pWaveDetected')
    ..aD(11, _omitFieldNames ? '' : 'estimatedPga',
        fieldType: $pb.PbFieldType.OF)
    ..aD(12, _omitFieldNames ? '' : 'reportedMagnitude',
        fieldType: $pb.PbFieldType.OF)
    ..a<$core.List<$core.int>>(
        15, _omitFieldNames ? '' : 'signature', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Observation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Observation copyWith(void Function(Observation) updates) =>
      super.copyWith((message) => updates(message as Observation))
          as Observation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Observation create() => Observation._();
  @$core.override
  Observation createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Observation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Observation>(create);
  static Observation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get protocolVersion => $_getIZ(0);
  @$pb.TagNumber(1)
  set protocolVersion($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProtocolVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearProtocolVersion() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get observationId => $_getN(1);
  @$pb.TagNumber(2)
  set observationId($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasObservationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearObservationId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get pubkey => $_getN(2);
  @$pb.TagNumber(3)
  set pubkey($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPubkey() => $_has(2);
  @$pb.TagNumber(3)
  void clearPubkey() => $_clearField(3);

  @$pb.TagNumber(4)
  SourceType get sourceType => $_getN(3);
  @$pb.TagNumber(4)
  set sourceType(SourceType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasSourceType() => $_has(3);
  @$pb.TagNumber(4)
  void clearSourceType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get sourceId => $_getSZ(4);
  @$pb.TagNumber(5)
  set sourceId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSourceId() => $_has(4);
  @$pb.TagNumber(5)
  void clearSourceId() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get capturedAtNs => $_getI64(5);
  @$pb.TagNumber(6)
  set capturedAtNs($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCapturedAtNs() => $_has(5);
  @$pb.TagNumber(6)
  void clearCapturedAtNs() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get clockUncertMs => $_getIZ(6);
  @$pb.TagNumber(7)
  set clockUncertMs($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasClockUncertMs() => $_has(6);
  @$pb.TagNumber(7)
  void clearClockUncertMs() => $_clearField(7);

  @$pb.TagNumber(8)
  Location get location => $_getN(7);
  @$pb.TagNumber(8)
  set location(Location value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasLocation() => $_has(7);
  @$pb.TagNumber(8)
  void clearLocation() => $_clearField(8);
  @$pb.TagNumber(8)
  Location ensureLocation() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.double get staLtaRatio => $_getN(8);
  @$pb.TagNumber(9)
  set staLtaRatio($core.double value) => $_setFloat(8, value);
  @$pb.TagNumber(9)
  $core.bool hasStaLtaRatio() => $_has(8);
  @$pb.TagNumber(9)
  void clearStaLtaRatio() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get pWaveDetected => $_getBF(9);
  @$pb.TagNumber(10)
  set pWaveDetected($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasPWaveDetected() => $_has(9);
  @$pb.TagNumber(10)
  void clearPWaveDetected() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get estimatedPga => $_getN(10);
  @$pb.TagNumber(11)
  set estimatedPga($core.double value) => $_setFloat(10, value);
  @$pb.TagNumber(11)
  $core.bool hasEstimatedPga() => $_has(10);
  @$pb.TagNumber(11)
  void clearEstimatedPga() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.double get reportedMagnitude => $_getN(11);
  @$pb.TagNumber(12)
  set reportedMagnitude($core.double value) => $_setFloat(11, value);
  @$pb.TagNumber(12)
  $core.bool hasReportedMagnitude() => $_has(11);
  @$pb.TagNumber(12)
  void clearReportedMagnitude() => $_clearField(12);

  @$pb.TagNumber(15)
  $core.List<$core.int> get signature => $_getN(12);
  @$pb.TagNumber(15)
  set signature($core.List<$core.int> value) => $_setBytes(12, value);
  @$pb.TagNumber(15)
  $core.bool hasSignature() => $_has(12);
  @$pb.TagNumber(15)
  void clearSignature() => $_clearField(15);
}

class ConfirmedEvent extends $pb.GeneratedMessage {
  factory ConfirmedEvent({
    $core.int? protocolVersion,
    $core.List<$core.int>? eventId,
    $core.List<$core.int>? pubkey,
    $fixnum.Int64? originTimeNs,
    $fixnum.Int64? issuedAtNs,
    Location? epicenter,
    $core.double? depthKm,
    $core.double? magnitude,
    $core.double? magnitudeUncert,
    EvidenceKind? evidence,
    $core.int? numObservations,
    $core.Iterable<$core.List<$core.int>>? obsIds,
    $core.List<$core.int>? supersedes,
    $core.List<$core.int>? signature,
  }) {
    final result = create();
    if (protocolVersion != null) result.protocolVersion = protocolVersion;
    if (eventId != null) result.eventId = eventId;
    if (pubkey != null) result.pubkey = pubkey;
    if (originTimeNs != null) result.originTimeNs = originTimeNs;
    if (issuedAtNs != null) result.issuedAtNs = issuedAtNs;
    if (epicenter != null) result.epicenter = epicenter;
    if (depthKm != null) result.depthKm = depthKm;
    if (magnitude != null) result.magnitude = magnitude;
    if (magnitudeUncert != null) result.magnitudeUncert = magnitudeUncert;
    if (evidence != null) result.evidence = evidence;
    if (numObservations != null) result.numObservations = numObservations;
    if (obsIds != null) result.obsIds.addAll(obsIds);
    if (supersedes != null) result.supersedes = supersedes;
    if (signature != null) result.signature = signature;
    return result;
  }

  ConfirmedEvent._();

  factory ConfirmedEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ConfirmedEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ConfirmedEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'earthnet.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'protocolVersion',
        fieldType: $pb.PbFieldType.OU3)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'eventId', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'pubkey', $pb.PbFieldType.OY)
    ..aInt64(4, _omitFieldNames ? '' : 'originTimeNs')
    ..aInt64(5, _omitFieldNames ? '' : 'issuedAtNs')
    ..aOM<Location>(6, _omitFieldNames ? '' : 'epicenter',
        subBuilder: Location.create)
    ..aD(7, _omitFieldNames ? '' : 'depthKm', fieldType: $pb.PbFieldType.OF)
    ..aD(8, _omitFieldNames ? '' : 'magnitude', fieldType: $pb.PbFieldType.OF)
    ..aD(9, _omitFieldNames ? '' : 'magnitudeUncert',
        fieldType: $pb.PbFieldType.OF)
    ..aE<EvidenceKind>(10, _omitFieldNames ? '' : 'evidence',
        enumValues: EvidenceKind.values)
    ..aI(11, _omitFieldNames ? '' : 'numObservations',
        fieldType: $pb.PbFieldType.OU3)
    ..p<$core.List<$core.int>>(
        12, _omitFieldNames ? '' : 'obsIds', $pb.PbFieldType.PY)
    ..a<$core.List<$core.int>>(
        13, _omitFieldNames ? '' : 'supersedes', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        15, _omitFieldNames ? '' : 'signature', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfirmedEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConfirmedEvent copyWith(void Function(ConfirmedEvent) updates) =>
      super.copyWith((message) => updates(message as ConfirmedEvent))
          as ConfirmedEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConfirmedEvent create() => ConfirmedEvent._();
  @$core.override
  ConfirmedEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ConfirmedEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ConfirmedEvent>(create);
  static ConfirmedEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get protocolVersion => $_getIZ(0);
  @$pb.TagNumber(1)
  set protocolVersion($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProtocolVersion() => $_has(0);
  @$pb.TagNumber(1)
  void clearProtocolVersion() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get eventId => $_getN(1);
  @$pb.TagNumber(2)
  set eventId($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEventId() => $_has(1);
  @$pb.TagNumber(2)
  void clearEventId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get pubkey => $_getN(2);
  @$pb.TagNumber(3)
  set pubkey($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPubkey() => $_has(2);
  @$pb.TagNumber(3)
  void clearPubkey() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get originTimeNs => $_getI64(3);
  @$pb.TagNumber(4)
  set originTimeNs($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOriginTimeNs() => $_has(3);
  @$pb.TagNumber(4)
  void clearOriginTimeNs() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get issuedAtNs => $_getI64(4);
  @$pb.TagNumber(5)
  set issuedAtNs($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIssuedAtNs() => $_has(4);
  @$pb.TagNumber(5)
  void clearIssuedAtNs() => $_clearField(5);

  @$pb.TagNumber(6)
  Location get epicenter => $_getN(5);
  @$pb.TagNumber(6)
  set epicenter(Location value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasEpicenter() => $_has(5);
  @$pb.TagNumber(6)
  void clearEpicenter() => $_clearField(6);
  @$pb.TagNumber(6)
  Location ensureEpicenter() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.double get depthKm => $_getN(6);
  @$pb.TagNumber(7)
  set depthKm($core.double value) => $_setFloat(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDepthKm() => $_has(6);
  @$pb.TagNumber(7)
  void clearDepthKm() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get magnitude => $_getN(7);
  @$pb.TagNumber(8)
  set magnitude($core.double value) => $_setFloat(7, value);
  @$pb.TagNumber(8)
  $core.bool hasMagnitude() => $_has(7);
  @$pb.TagNumber(8)
  void clearMagnitude() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get magnitudeUncert => $_getN(8);
  @$pb.TagNumber(9)
  set magnitudeUncert($core.double value) => $_setFloat(8, value);
  @$pb.TagNumber(9)
  $core.bool hasMagnitudeUncert() => $_has(8);
  @$pb.TagNumber(9)
  void clearMagnitudeUncert() => $_clearField(9);

  @$pb.TagNumber(10)
  EvidenceKind get evidence => $_getN(9);
  @$pb.TagNumber(10)
  set evidence(EvidenceKind value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasEvidence() => $_has(9);
  @$pb.TagNumber(10)
  void clearEvidence() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get numObservations => $_getIZ(10);
  @$pb.TagNumber(11)
  set numObservations($core.int value) => $_setUnsignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasNumObservations() => $_has(10);
  @$pb.TagNumber(11)
  void clearNumObservations() => $_clearField(11);

  @$pb.TagNumber(12)
  $pb.PbList<$core.List<$core.int>> get obsIds => $_getList(11);

  @$pb.TagNumber(13)
  $core.List<$core.int> get supersedes => $_getN(12);
  @$pb.TagNumber(13)
  set supersedes($core.List<$core.int> value) => $_setBytes(12, value);
  @$pb.TagNumber(13)
  $core.bool hasSupersedes() => $_has(12);
  @$pb.TagNumber(13)
  void clearSupersedes() => $_clearField(13);

  @$pb.TagNumber(15)
  $core.List<$core.int> get signature => $_getN(13);
  @$pb.TagNumber(15)
  set signature($core.List<$core.int> value) => $_setBytes(13, value);
  @$pb.TagNumber(15)
  $core.bool hasSignature() => $_has(13);
  @$pb.TagNumber(15)
  void clearSignature() => $_clearField(15);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
