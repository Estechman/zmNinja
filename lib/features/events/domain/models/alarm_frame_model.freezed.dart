// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alarm_frame_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AlarmFrame _$AlarmFrameFromJson(Map<String, dynamic> json) {
  return _AlarmFrame.fromJson(json);
}

/// @nodoc
mixin _$AlarmFrame {
  int get frameNumber => throw _privateConstructorUsedError;
  double get timestamp => throw _privateConstructorUsedError;
  double get score => throw _privateConstructorUsedError;
  String get imagePath => throw _privateConstructorUsedError;
  String? get cause => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this AlarmFrame to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AlarmFrame
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AlarmFrameCopyWith<AlarmFrame> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlarmFrameCopyWith<$Res> {
  factory $AlarmFrameCopyWith(
    AlarmFrame value,
    $Res Function(AlarmFrame) then,
  ) = _$AlarmFrameCopyWithImpl<$Res, AlarmFrame>;
  @useResult
  $Res call({
    int frameNumber,
    double timestamp,
    double score,
    String imagePath,
    String? cause,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$AlarmFrameCopyWithImpl<$Res, $Val extends AlarmFrame>
    implements $AlarmFrameCopyWith<$Res> {
  _$AlarmFrameCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AlarmFrame
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? frameNumber = null,
    Object? timestamp = null,
    Object? score = null,
    Object? imagePath = null,
    Object? cause = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            frameNumber: null == frameNumber
                ? _value.frameNumber
                : frameNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as double,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as double,
            imagePath: null == imagePath
                ? _value.imagePath
                : imagePath // ignore: cast_nullable_to_non_nullable
                      as String,
            cause: freezed == cause
                ? _value.cause
                : cause // ignore: cast_nullable_to_non_nullable
                      as String?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AlarmFrameImplCopyWith<$Res>
    implements $AlarmFrameCopyWith<$Res> {
  factory _$$AlarmFrameImplCopyWith(
    _$AlarmFrameImpl value,
    $Res Function(_$AlarmFrameImpl) then,
  ) = __$$AlarmFrameImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int frameNumber,
    double timestamp,
    double score,
    String imagePath,
    String? cause,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$AlarmFrameImplCopyWithImpl<$Res>
    extends _$AlarmFrameCopyWithImpl<$Res, _$AlarmFrameImpl>
    implements _$$AlarmFrameImplCopyWith<$Res> {
  __$$AlarmFrameImplCopyWithImpl(
    _$AlarmFrameImpl _value,
    $Res Function(_$AlarmFrameImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AlarmFrame
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? frameNumber = null,
    Object? timestamp = null,
    Object? score = null,
    Object? imagePath = null,
    Object? cause = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$AlarmFrameImpl(
        frameNumber: null == frameNumber
            ? _value.frameNumber
            : frameNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as double,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as double,
        imagePath: null == imagePath
            ? _value.imagePath
            : imagePath // ignore: cast_nullable_to_non_nullable
                  as String,
        cause: freezed == cause
            ? _value.cause
            : cause // ignore: cast_nullable_to_non_nullable
                  as String?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AlarmFrameImpl implements _AlarmFrame {
  const _$AlarmFrameImpl({
    required this.frameNumber,
    required this.timestamp,
    required this.score,
    required this.imagePath,
    this.cause,
    final Map<String, dynamic>? metadata,
  }) : _metadata = metadata;

  factory _$AlarmFrameImpl.fromJson(Map<String, dynamic> json) =>
      _$$AlarmFrameImplFromJson(json);

  @override
  final int frameNumber;
  @override
  final double timestamp;
  @override
  final double score;
  @override
  final String imagePath;
  @override
  final String? cause;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AlarmFrame(frameNumber: $frameNumber, timestamp: $timestamp, score: $score, imagePath: $imagePath, cause: $cause, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlarmFrameImpl &&
            (identical(other.frameNumber, frameNumber) ||
                other.frameNumber == frameNumber) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.cause, cause) || other.cause == cause) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    frameNumber,
    timestamp,
    score,
    imagePath,
    cause,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of AlarmFrame
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AlarmFrameImplCopyWith<_$AlarmFrameImpl> get copyWith =>
      __$$AlarmFrameImplCopyWithImpl<_$AlarmFrameImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AlarmFrameImplToJson(this);
  }
}

abstract class _AlarmFrame implements AlarmFrame {
  const factory _AlarmFrame({
    required final int frameNumber,
    required final double timestamp,
    required final double score,
    required final String imagePath,
    final String? cause,
    final Map<String, dynamic>? metadata,
  }) = _$AlarmFrameImpl;

  factory _AlarmFrame.fromJson(Map<String, dynamic> json) =
      _$AlarmFrameImpl.fromJson;

  @override
  int get frameNumber;
  @override
  double get timestamp;
  @override
  double get score;
  @override
  String get imagePath;
  @override
  String? get cause;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of AlarmFrame
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AlarmFrameImplCopyWith<_$AlarmFrameImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EventPlaybackState _$EventPlaybackStateFromJson(Map<String, dynamic> json) {
  return _EventPlaybackState.fromJson(json);
}

/// @nodoc
mixin _$EventPlaybackState {
  bool get isPlaying => throw _privateConstructorUsedError;
  int get currentFrame => throw _privateConstructorUsedError;
  double get playbackSpeed => throw _privateConstructorUsedError;
  bool get showAlarmFramesOnly => throw _privateConstructorUsedError;
  List<AlarmFrame> get alarmFrames => throw _privateConstructorUsedError;
  int get totalFrames => throw _privateConstructorUsedError;

  /// Serializes this EventPlaybackState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EventPlaybackState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventPlaybackStateCopyWith<EventPlaybackState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventPlaybackStateCopyWith<$Res> {
  factory $EventPlaybackStateCopyWith(
    EventPlaybackState value,
    $Res Function(EventPlaybackState) then,
  ) = _$EventPlaybackStateCopyWithImpl<$Res, EventPlaybackState>;
  @useResult
  $Res call({
    bool isPlaying,
    int currentFrame,
    double playbackSpeed,
    bool showAlarmFramesOnly,
    List<AlarmFrame> alarmFrames,
    int totalFrames,
  });
}

/// @nodoc
class _$EventPlaybackStateCopyWithImpl<$Res, $Val extends EventPlaybackState>
    implements $EventPlaybackStateCopyWith<$Res> {
  _$EventPlaybackStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EventPlaybackState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPlaying = null,
    Object? currentFrame = null,
    Object? playbackSpeed = null,
    Object? showAlarmFramesOnly = null,
    Object? alarmFrames = null,
    Object? totalFrames = null,
  }) {
    return _then(
      _value.copyWith(
            isPlaying: null == isPlaying
                ? _value.isPlaying
                : isPlaying // ignore: cast_nullable_to_non_nullable
                      as bool,
            currentFrame: null == currentFrame
                ? _value.currentFrame
                : currentFrame // ignore: cast_nullable_to_non_nullable
                      as int,
            playbackSpeed: null == playbackSpeed
                ? _value.playbackSpeed
                : playbackSpeed // ignore: cast_nullable_to_non_nullable
                      as double,
            showAlarmFramesOnly: null == showAlarmFramesOnly
                ? _value.showAlarmFramesOnly
                : showAlarmFramesOnly // ignore: cast_nullable_to_non_nullable
                      as bool,
            alarmFrames: null == alarmFrames
                ? _value.alarmFrames
                : alarmFrames // ignore: cast_nullable_to_non_nullable
                      as List<AlarmFrame>,
            totalFrames: null == totalFrames
                ? _value.totalFrames
                : totalFrames // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EventPlaybackStateImplCopyWith<$Res>
    implements $EventPlaybackStateCopyWith<$Res> {
  factory _$$EventPlaybackStateImplCopyWith(
    _$EventPlaybackStateImpl value,
    $Res Function(_$EventPlaybackStateImpl) then,
  ) = __$$EventPlaybackStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isPlaying,
    int currentFrame,
    double playbackSpeed,
    bool showAlarmFramesOnly,
    List<AlarmFrame> alarmFrames,
    int totalFrames,
  });
}

/// @nodoc
class __$$EventPlaybackStateImplCopyWithImpl<$Res>
    extends _$EventPlaybackStateCopyWithImpl<$Res, _$EventPlaybackStateImpl>
    implements _$$EventPlaybackStateImplCopyWith<$Res> {
  __$$EventPlaybackStateImplCopyWithImpl(
    _$EventPlaybackStateImpl _value,
    $Res Function(_$EventPlaybackStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EventPlaybackState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isPlaying = null,
    Object? currentFrame = null,
    Object? playbackSpeed = null,
    Object? showAlarmFramesOnly = null,
    Object? alarmFrames = null,
    Object? totalFrames = null,
  }) {
    return _then(
      _$EventPlaybackStateImpl(
        isPlaying: null == isPlaying
            ? _value.isPlaying
            : isPlaying // ignore: cast_nullable_to_non_nullable
                  as bool,
        currentFrame: null == currentFrame
            ? _value.currentFrame
            : currentFrame // ignore: cast_nullable_to_non_nullable
                  as int,
        playbackSpeed: null == playbackSpeed
            ? _value.playbackSpeed
            : playbackSpeed // ignore: cast_nullable_to_non_nullable
                  as double,
        showAlarmFramesOnly: null == showAlarmFramesOnly
            ? _value.showAlarmFramesOnly
            : showAlarmFramesOnly // ignore: cast_nullable_to_non_nullable
                  as bool,
        alarmFrames: null == alarmFrames
            ? _value._alarmFrames
            : alarmFrames // ignore: cast_nullable_to_non_nullable
                  as List<AlarmFrame>,
        totalFrames: null == totalFrames
            ? _value.totalFrames
            : totalFrames // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EventPlaybackStateImpl implements _EventPlaybackState {
  const _$EventPlaybackStateImpl({
    this.isPlaying = false,
    this.currentFrame = 0,
    this.playbackSpeed = 0.0,
    this.showAlarmFramesOnly = false,
    final List<AlarmFrame> alarmFrames = const [],
    this.totalFrames = 0,
  }) : _alarmFrames = alarmFrames;

  factory _$EventPlaybackStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventPlaybackStateImplFromJson(json);

  @override
  @JsonKey()
  final bool isPlaying;
  @override
  @JsonKey()
  final int currentFrame;
  @override
  @JsonKey()
  final double playbackSpeed;
  @override
  @JsonKey()
  final bool showAlarmFramesOnly;
  final List<AlarmFrame> _alarmFrames;
  @override
  @JsonKey()
  List<AlarmFrame> get alarmFrames {
    if (_alarmFrames is EqualUnmodifiableListView) return _alarmFrames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alarmFrames);
  }

  @override
  @JsonKey()
  final int totalFrames;

  @override
  String toString() {
    return 'EventPlaybackState(isPlaying: $isPlaying, currentFrame: $currentFrame, playbackSpeed: $playbackSpeed, showAlarmFramesOnly: $showAlarmFramesOnly, alarmFrames: $alarmFrames, totalFrames: $totalFrames)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventPlaybackStateImpl &&
            (identical(other.isPlaying, isPlaying) ||
                other.isPlaying == isPlaying) &&
            (identical(other.currentFrame, currentFrame) ||
                other.currentFrame == currentFrame) &&
            (identical(other.playbackSpeed, playbackSpeed) ||
                other.playbackSpeed == playbackSpeed) &&
            (identical(other.showAlarmFramesOnly, showAlarmFramesOnly) ||
                other.showAlarmFramesOnly == showAlarmFramesOnly) &&
            const DeepCollectionEquality().equals(
              other._alarmFrames,
              _alarmFrames,
            ) &&
            (identical(other.totalFrames, totalFrames) ||
                other.totalFrames == totalFrames));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    isPlaying,
    currentFrame,
    playbackSpeed,
    showAlarmFramesOnly,
    const DeepCollectionEquality().hash(_alarmFrames),
    totalFrames,
  );

  /// Create a copy of EventPlaybackState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventPlaybackStateImplCopyWith<_$EventPlaybackStateImpl> get copyWith =>
      __$$EventPlaybackStateImplCopyWithImpl<_$EventPlaybackStateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$EventPlaybackStateImplToJson(this);
  }
}

abstract class _EventPlaybackState implements EventPlaybackState {
  const factory _EventPlaybackState({
    final bool isPlaying,
    final int currentFrame,
    final double playbackSpeed,
    final bool showAlarmFramesOnly,
    final List<AlarmFrame> alarmFrames,
    final int totalFrames,
  }) = _$EventPlaybackStateImpl;

  factory _EventPlaybackState.fromJson(Map<String, dynamic> json) =
      _$EventPlaybackStateImpl.fromJson;

  @override
  bool get isPlaying;
  @override
  int get currentFrame;
  @override
  double get playbackSpeed;
  @override
  bool get showAlarmFramesOnly;
  @override
  List<AlarmFrame> get alarmFrames;
  @override
  int get totalFrames;

  /// Create a copy of EventPlaybackState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventPlaybackStateImplCopyWith<_$EventPlaybackStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
