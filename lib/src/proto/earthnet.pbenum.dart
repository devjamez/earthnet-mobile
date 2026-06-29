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

import 'package:protobuf/protobuf.dart' as $pb;

class SourceType extends $pb.ProtobufEnum {
  static const SourceType SOURCE_TYPE_UNSPECIFIED =
      SourceType._(0, _omitEnumNames ? '' : 'SOURCE_TYPE_UNSPECIFIED');
  static const SourceType SOURCE_TYPE_OFFICIAL =
      SourceType._(1, _omitEnumNames ? '' : 'SOURCE_TYPE_OFFICIAL');
  static const SourceType SOURCE_TYPE_PHONE =
      SourceType._(2, _omitEnumNames ? '' : 'SOURCE_TYPE_PHONE');

  static const $core.List<SourceType> values = <SourceType>[
    SOURCE_TYPE_UNSPECIFIED,
    SOURCE_TYPE_OFFICIAL,
    SOURCE_TYPE_PHONE,
  ];

  static final $core.List<SourceType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static SourceType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SourceType._(super.value, super.name);
}

class EvidenceKind extends $pb.ProtobufEnum {
  static const EvidenceKind EVIDENCE_KIND_UNSPECIFIED =
      EvidenceKind._(0, _omitEnumNames ? '' : 'EVIDENCE_KIND_UNSPECIFIED');
  static const EvidenceKind EVIDENCE_KIND_OFFICIAL =
      EvidenceKind._(1, _omitEnumNames ? '' : 'EVIDENCE_KIND_OFFICIAL');
  static const EvidenceKind EVIDENCE_KIND_CONSENSUS =
      EvidenceKind._(2, _omitEnumNames ? '' : 'EVIDENCE_KIND_CONSENSUS');
  static const EvidenceKind EVIDENCE_KIND_BOTH =
      EvidenceKind._(3, _omitEnumNames ? '' : 'EVIDENCE_KIND_BOTH');

  static const $core.List<EvidenceKind> values = <EvidenceKind>[
    EVIDENCE_KIND_UNSPECIFIED,
    EVIDENCE_KIND_OFFICIAL,
    EVIDENCE_KIND_CONSENSUS,
    EVIDENCE_KIND_BOTH,
  ];

  static final $core.List<EvidenceKind?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static EvidenceKind? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const EvidenceKind._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
