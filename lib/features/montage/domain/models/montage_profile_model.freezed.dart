// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'montage_profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MontageProfile _$MontageProfileFromJson(Map<String, dynamic> json) {
  return _MontageProfile.fromJson(json);
}

/// @nodoc
mixin _$MontageProfile {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<CameraLayout> get cameraLayouts => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this MontageProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MontageProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MontageProfileCopyWith<MontageProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MontageProfileCopyWith<$Res> {
  factory $MontageProfileCopyWith(
    MontageProfile value,
    $Res Function(MontageProfile) then,
  ) = _$MontageProfileCopyWithImpl<$Res, MontageProfile>;
  @useResult
  $Res call({
    String id,
    String name,
    List<CameraLayout> cameraLayouts,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$MontageProfileCopyWithImpl<$Res, $Val extends MontageProfile>
    implements $MontageProfileCopyWith<$Res> {
  _$MontageProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MontageProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? cameraLayouts = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            cameraLayouts: null == cameraLayouts
                ? _value.cameraLayouts
                : cameraLayouts // ignore: cast_nullable_to_non_nullable
                      as List<CameraLayout>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MontageProfileImplCopyWith<$Res>
    implements $MontageProfileCopyWith<$Res> {
  factory _$$MontageProfileImplCopyWith(
    _$MontageProfileImpl value,
    $Res Function(_$MontageProfileImpl) then,
  ) = __$$MontageProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    List<CameraLayout> cameraLayouts,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$MontageProfileImplCopyWithImpl<$Res>
    extends _$MontageProfileCopyWithImpl<$Res, _$MontageProfileImpl>
    implements _$$MontageProfileImplCopyWith<$Res> {
  __$$MontageProfileImplCopyWithImpl(
    _$MontageProfileImpl _value,
    $Res Function(_$MontageProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MontageProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? cameraLayouts = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$MontageProfileImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        cameraLayouts: null == cameraLayouts
            ? _value._cameraLayouts
            : cameraLayouts // ignore: cast_nullable_to_non_nullable
                  as List<CameraLayout>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MontageProfileImpl implements _MontageProfile {
  const _$MontageProfileImpl({
    required this.id,
    required this.name,
    required final List<CameraLayout> cameraLayouts,
    required this.createdAt,
    this.updatedAt,
  }) : _cameraLayouts = cameraLayouts;

  factory _$MontageProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$MontageProfileImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  final List<CameraLayout> _cameraLayouts;
  @override
  List<CameraLayout> get cameraLayouts {
    if (_cameraLayouts is EqualUnmodifiableListView) return _cameraLayouts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cameraLayouts);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'MontageProfile(id: $id, name: $name, cameraLayouts: $cameraLayouts, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MontageProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(
              other._cameraLayouts,
              _cameraLayouts,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    const DeepCollectionEquality().hash(_cameraLayouts),
    createdAt,
    updatedAt,
  );

  /// Create a copy of MontageProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MontageProfileImplCopyWith<_$MontageProfileImpl> get copyWith =>
      __$$MontageProfileImplCopyWithImpl<_$MontageProfileImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MontageProfileImplToJson(this);
  }
}

abstract class _MontageProfile implements MontageProfile {
  const factory _MontageProfile({
    required final String id,
    required final String name,
    required final List<CameraLayout> cameraLayouts,
    required final DateTime createdAt,
    final DateTime? updatedAt,
  }) = _$MontageProfileImpl;

  factory _MontageProfile.fromJson(Map<String, dynamic> json) =
      _$MontageProfileImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  List<CameraLayout> get cameraLayouts;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of MontageProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MontageProfileImplCopyWith<_$MontageProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CameraLayout _$CameraLayoutFromJson(Map<String, dynamic> json) {
  return _CameraLayout.fromJson(json);
}

/// @nodoc
mixin _$CameraLayout {
  String get cameraId => throw _privateConstructorUsedError;
  double get x => throw _privateConstructorUsedError;
  double get y => throw _privateConstructorUsedError;
  double get width => throw _privateConstructorUsedError;
  double get height => throw _privateConstructorUsedError;
  bool get visible => throw _privateConstructorUsedError;
  int get gridScale => throw _privateConstructorUsedError;

  /// Serializes this CameraLayout to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CameraLayout
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CameraLayoutCopyWith<CameraLayout> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CameraLayoutCopyWith<$Res> {
  factory $CameraLayoutCopyWith(
    CameraLayout value,
    $Res Function(CameraLayout) then,
  ) = _$CameraLayoutCopyWithImpl<$Res, CameraLayout>;
  @useResult
  $Res call({
    String cameraId,
    double x,
    double y,
    double width,
    double height,
    bool visible,
    int gridScale,
  });
}

/// @nodoc
class _$CameraLayoutCopyWithImpl<$Res, $Val extends CameraLayout>
    implements $CameraLayoutCopyWith<$Res> {
  _$CameraLayoutCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CameraLayout
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cameraId = null,
    Object? x = null,
    Object? y = null,
    Object? width = null,
    Object? height = null,
    Object? visible = null,
    Object? gridScale = null,
  }) {
    return _then(
      _value.copyWith(
            cameraId: null == cameraId
                ? _value.cameraId
                : cameraId // ignore: cast_nullable_to_non_nullable
                      as String,
            x: null == x
                ? _value.x
                : x // ignore: cast_nullable_to_non_nullable
                      as double,
            y: null == y
                ? _value.y
                : y // ignore: cast_nullable_to_non_nullable
                      as double,
            width: null == width
                ? _value.width
                : width // ignore: cast_nullable_to_non_nullable
                      as double,
            height: null == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                      as double,
            visible: null == visible
                ? _value.visible
                : visible // ignore: cast_nullable_to_non_nullable
                      as bool,
            gridScale: null == gridScale
                ? _value.gridScale
                : gridScale // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CameraLayoutImplCopyWith<$Res>
    implements $CameraLayoutCopyWith<$Res> {
  factory _$$CameraLayoutImplCopyWith(
    _$CameraLayoutImpl value,
    $Res Function(_$CameraLayoutImpl) then,
  ) = __$$CameraLayoutImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String cameraId,
    double x,
    double y,
    double width,
    double height,
    bool visible,
    int gridScale,
  });
}

/// @nodoc
class __$$CameraLayoutImplCopyWithImpl<$Res>
    extends _$CameraLayoutCopyWithImpl<$Res, _$CameraLayoutImpl>
    implements _$$CameraLayoutImplCopyWith<$Res> {
  __$$CameraLayoutImplCopyWithImpl(
    _$CameraLayoutImpl _value,
    $Res Function(_$CameraLayoutImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CameraLayout
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cameraId = null,
    Object? x = null,
    Object? y = null,
    Object? width = null,
    Object? height = null,
    Object? visible = null,
    Object? gridScale = null,
  }) {
    return _then(
      _$CameraLayoutImpl(
        cameraId: null == cameraId
            ? _value.cameraId
            : cameraId // ignore: cast_nullable_to_non_nullable
                  as String,
        x: null == x
            ? _value.x
            : x // ignore: cast_nullable_to_non_nullable
                  as double,
        y: null == y
            ? _value.y
            : y // ignore: cast_nullable_to_non_nullable
                  as double,
        width: null == width
            ? _value.width
            : width // ignore: cast_nullable_to_non_nullable
                  as double,
        height: null == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as double,
        visible: null == visible
            ? _value.visible
            : visible // ignore: cast_nullable_to_non_nullable
                  as bool,
        gridScale: null == gridScale
            ? _value.gridScale
            : gridScale // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CameraLayoutImpl implements _CameraLayout {
  const _$CameraLayoutImpl({
    required this.cameraId,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.visible,
    this.gridScale = 20,
  });

  factory _$CameraLayoutImpl.fromJson(Map<String, dynamic> json) =>
      _$$CameraLayoutImplFromJson(json);

  @override
  final String cameraId;
  @override
  final double x;
  @override
  final double y;
  @override
  final double width;
  @override
  final double height;
  @override
  final bool visible;
  @override
  @JsonKey()
  final int gridScale;

  @override
  String toString() {
    return 'CameraLayout(cameraId: $cameraId, x: $x, y: $y, width: $width, height: $height, visible: $visible, gridScale: $gridScale)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CameraLayoutImpl &&
            (identical(other.cameraId, cameraId) ||
                other.cameraId == cameraId) &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.visible, visible) || other.visible == visible) &&
            (identical(other.gridScale, gridScale) ||
                other.gridScale == gridScale));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    cameraId,
    x,
    y,
    width,
    height,
    visible,
    gridScale,
  );

  /// Create a copy of CameraLayout
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CameraLayoutImplCopyWith<_$CameraLayoutImpl> get copyWith =>
      __$$CameraLayoutImplCopyWithImpl<_$CameraLayoutImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CameraLayoutImplToJson(this);
  }
}

abstract class _CameraLayout implements CameraLayout {
  const factory _CameraLayout({
    required final String cameraId,
    required final double x,
    required final double y,
    required final double width,
    required final double height,
    required final bool visible,
    final int gridScale,
  }) = _$CameraLayoutImpl;

  factory _CameraLayout.fromJson(Map<String, dynamic> json) =
      _$CameraLayoutImpl.fromJson;

  @override
  String get cameraId;
  @override
  double get x;
  @override
  double get y;
  @override
  double get width;
  @override
  double get height;
  @override
  bool get visible;
  @override
  int get gridScale;

  /// Create a copy of CameraLayout
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CameraLayoutImplCopyWith<_$CameraLayoutImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AlarmStatusUpdate _$AlarmStatusUpdateFromJson(Map<String, dynamic> json) {
  return _AlarmStatusUpdate.fromJson(json);
}

/// @nodoc
mixin _$AlarmStatusUpdate {
  String get cameraId => throw _privateConstructorUsedError;
  AlarmStatus get status => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  int? get eventCount => throw _privateConstructorUsedError;

  /// Serializes this AlarmStatusUpdate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AlarmStatusUpdate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AlarmStatusUpdateCopyWith<AlarmStatusUpdate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlarmStatusUpdateCopyWith<$Res> {
  factory $AlarmStatusUpdateCopyWith(
    AlarmStatusUpdate value,
    $Res Function(AlarmStatusUpdate) then,
  ) = _$AlarmStatusUpdateCopyWithImpl<$Res, AlarmStatusUpdate>;
  @useResult
  $Res call({
    String cameraId,
    AlarmStatus status,
    DateTime timestamp,
    int? eventCount,
  });
}

/// @nodoc
class _$AlarmStatusUpdateCopyWithImpl<$Res, $Val extends AlarmStatusUpdate>
    implements $AlarmStatusUpdateCopyWith<$Res> {
  _$AlarmStatusUpdateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AlarmStatusUpdate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cameraId = null,
    Object? status = null,
    Object? timestamp = null,
    Object? eventCount = freezed,
  }) {
    return _then(
      _value.copyWith(
            cameraId: null == cameraId
                ? _value.cameraId
                : cameraId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as AlarmStatus,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            eventCount: freezed == eventCount
                ? _value.eventCount
                : eventCount // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AlarmStatusUpdateImplCopyWith<$Res>
    implements $AlarmStatusUpdateCopyWith<$Res> {
  factory _$$AlarmStatusUpdateImplCopyWith(
    _$AlarmStatusUpdateImpl value,
    $Res Function(_$AlarmStatusUpdateImpl) then,
  ) = __$$AlarmStatusUpdateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String cameraId,
    AlarmStatus status,
    DateTime timestamp,
    int? eventCount,
  });
}

/// @nodoc
class __$$AlarmStatusUpdateImplCopyWithImpl<$Res>
    extends _$AlarmStatusUpdateCopyWithImpl<$Res, _$AlarmStatusUpdateImpl>
    implements _$$AlarmStatusUpdateImplCopyWith<$Res> {
  __$$AlarmStatusUpdateImplCopyWithImpl(
    _$AlarmStatusUpdateImpl _value,
    $Res Function(_$AlarmStatusUpdateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AlarmStatusUpdate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cameraId = null,
    Object? status = null,
    Object? timestamp = null,
    Object? eventCount = freezed,
  }) {
    return _then(
      _$AlarmStatusUpdateImpl(
        cameraId: null == cameraId
            ? _value.cameraId
            : cameraId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as AlarmStatus,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        eventCount: freezed == eventCount
            ? _value.eventCount
            : eventCount // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AlarmStatusUpdateImpl implements _AlarmStatusUpdate {
  const _$AlarmStatusUpdateImpl({
    required this.cameraId,
    required this.status,
    required this.timestamp,
    this.eventCount,
  });

  factory _$AlarmStatusUpdateImpl.fromJson(Map<String, dynamic> json) =>
      _$$AlarmStatusUpdateImplFromJson(json);

  @override
  final String cameraId;
  @override
  final AlarmStatus status;
  @override
  final DateTime timestamp;
  @override
  final int? eventCount;

  @override
  String toString() {
    return 'AlarmStatusUpdate(cameraId: $cameraId, status: $status, timestamp: $timestamp, eventCount: $eventCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlarmStatusUpdateImpl &&
            (identical(other.cameraId, cameraId) ||
                other.cameraId == cameraId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.eventCount, eventCount) ||
                other.eventCount == eventCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, cameraId, status, timestamp, eventCount);

  /// Create a copy of AlarmStatusUpdate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AlarmStatusUpdateImplCopyWith<_$AlarmStatusUpdateImpl> get copyWith =>
      __$$AlarmStatusUpdateImplCopyWithImpl<_$AlarmStatusUpdateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AlarmStatusUpdateImplToJson(this);
  }
}

abstract class _AlarmStatusUpdate implements AlarmStatusUpdate {
  const factory _AlarmStatusUpdate({
    required final String cameraId,
    required final AlarmStatus status,
    required final DateTime timestamp,
    final int? eventCount,
  }) = _$AlarmStatusUpdateImpl;

  factory _AlarmStatusUpdate.fromJson(Map<String, dynamic> json) =
      _$AlarmStatusUpdateImpl.fromJson;

  @override
  String get cameraId;
  @override
  AlarmStatus get status;
  @override
  DateTime get timestamp;
  @override
  int? get eventCount;

  /// Create a copy of AlarmStatusUpdate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AlarmStatusUpdateImplCopyWith<_$AlarmStatusUpdateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EventCountUpdate _$EventCountUpdateFromJson(Map<String, dynamic> json) {
  return _EventCountUpdate.fromJson(json);
}

/// @nodoc
mixin _$EventCountUpdate {
  String get cameraId => throw _privateConstructorUsedError;
  String get newEventId => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this EventCountUpdate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EventCountUpdate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventCountUpdateCopyWith<EventCountUpdate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventCountUpdateCopyWith<$Res> {
  factory $EventCountUpdateCopyWith(
    EventCountUpdate value,
    $Res Function(EventCountUpdate) then,
  ) = _$EventCountUpdateCopyWithImpl<$Res, EventCountUpdate>;
  @useResult
  $Res call({String cameraId, String newEventId, DateTime timestamp});
}

/// @nodoc
class _$EventCountUpdateCopyWithImpl<$Res, $Val extends EventCountUpdate>
    implements $EventCountUpdateCopyWith<$Res> {
  _$EventCountUpdateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EventCountUpdate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cameraId = null,
    Object? newEventId = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            cameraId: null == cameraId
                ? _value.cameraId
                : cameraId // ignore: cast_nullable_to_non_nullable
                      as String,
            newEventId: null == newEventId
                ? _value.newEventId
                : newEventId // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EventCountUpdateImplCopyWith<$Res>
    implements $EventCountUpdateCopyWith<$Res> {
  factory _$$EventCountUpdateImplCopyWith(
    _$EventCountUpdateImpl value,
    $Res Function(_$EventCountUpdateImpl) then,
  ) = __$$EventCountUpdateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String cameraId, String newEventId, DateTime timestamp});
}

/// @nodoc
class __$$EventCountUpdateImplCopyWithImpl<$Res>
    extends _$EventCountUpdateCopyWithImpl<$Res, _$EventCountUpdateImpl>
    implements _$$EventCountUpdateImplCopyWith<$Res> {
  __$$EventCountUpdateImplCopyWithImpl(
    _$EventCountUpdateImpl _value,
    $Res Function(_$EventCountUpdateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EventCountUpdate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cameraId = null,
    Object? newEventId = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$EventCountUpdateImpl(
        cameraId: null == cameraId
            ? _value.cameraId
            : cameraId // ignore: cast_nullable_to_non_nullable
                  as String,
        newEventId: null == newEventId
            ? _value.newEventId
            : newEventId // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EventCountUpdateImpl implements _EventCountUpdate {
  const _$EventCountUpdateImpl({
    required this.cameraId,
    required this.newEventId,
    required this.timestamp,
  });

  factory _$EventCountUpdateImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventCountUpdateImplFromJson(json);

  @override
  final String cameraId;
  @override
  final String newEventId;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'EventCountUpdate(cameraId: $cameraId, newEventId: $newEventId, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventCountUpdateImpl &&
            (identical(other.cameraId, cameraId) ||
                other.cameraId == cameraId) &&
            (identical(other.newEventId, newEventId) ||
                other.newEventId == newEventId) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, cameraId, newEventId, timestamp);

  /// Create a copy of EventCountUpdate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventCountUpdateImplCopyWith<_$EventCountUpdateImpl> get copyWith =>
      __$$EventCountUpdateImplCopyWithImpl<_$EventCountUpdateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EventCountUpdateImplToJson(this);
  }
}

abstract class _EventCountUpdate implements EventCountUpdate {
  const factory _EventCountUpdate({
    required final String cameraId,
    required final String newEventId,
    required final DateTime timestamp,
  }) = _$EventCountUpdateImpl;

  factory _EventCountUpdate.fromJson(Map<String, dynamic> json) =
      _$EventCountUpdateImpl.fromJson;

  @override
  String get cameraId;
  @override
  String get newEventId;
  @override
  DateTime get timestamp;

  /// Create a copy of EventCountUpdate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventCountUpdateImplCopyWith<_$EventCountUpdateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
