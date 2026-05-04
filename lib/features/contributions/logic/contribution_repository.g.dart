// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contribution_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contributionRepositoryHash() =>
    r'ce3cdf9b2af505b9d277aa7db552f96a6f8e5e6c';

/// See also [contributionRepository].
@ProviderFor(contributionRepository)
final contributionRepositoryProvider =
    AutoDisposeProvider<ContributionRepository>.internal(
  contributionRepository,
  name: r'contributionRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$contributionRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContributionRepositoryRef
    = AutoDisposeProviderRef<ContributionRepository>;
String _$touristStreamHash() => r'a876fe81edc965a55a7725d6d46e6f7957f0494b';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Streams the tourist's Firestore document so points/count stay live
/// even after an admin approves a contribution in the background.
///
/// Copied from [touristStream].
@ProviderFor(touristStream)
const touristStreamProvider = TouristStreamFamily();

/// Streams the tourist's Firestore document so points/count stay live
/// even after an admin approves a contribution in the background.
///
/// Copied from [touristStream].
class TouristStreamFamily extends Family<AsyncValue<TouristModel?>> {
  /// Streams the tourist's Firestore document so points/count stay live
  /// even after an admin approves a contribution in the background.
  ///
  /// Copied from [touristStream].
  const TouristStreamFamily();

  /// Streams the tourist's Firestore document so points/count stay live
  /// even after an admin approves a contribution in the background.
  ///
  /// Copied from [touristStream].
  TouristStreamProvider call(
    String uid,
  ) {
    return TouristStreamProvider(
      uid,
    );
  }

  @override
  TouristStreamProvider getProviderOverride(
    covariant TouristStreamProvider provider,
  ) {
    return call(
      provider.uid,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'touristStreamProvider';
}

/// Streams the tourist's Firestore document so points/count stay live
/// even after an admin approves a contribution in the background.
///
/// Copied from [touristStream].
class TouristStreamProvider extends AutoDisposeStreamProvider<TouristModel?> {
  /// Streams the tourist's Firestore document so points/count stay live
  /// even after an admin approves a contribution in the background.
  ///
  /// Copied from [touristStream].
  TouristStreamProvider(
    String uid,
  ) : this._internal(
          (ref) => touristStream(
            ref as TouristStreamRef,
            uid,
          ),
          from: touristStreamProvider,
          name: r'touristStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$touristStreamHash,
          dependencies: TouristStreamFamily._dependencies,
          allTransitiveDependencies:
              TouristStreamFamily._allTransitiveDependencies,
          uid: uid,
        );

  TouristStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.uid,
  }) : super.internal();

  final String uid;

  @override
  Override overrideWith(
    Stream<TouristModel?> Function(TouristStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TouristStreamProvider._internal(
        (ref) => create(ref as TouristStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        uid: uid,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<TouristModel?> createElement() {
    return _TouristStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TouristStreamProvider && other.uid == uid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, uid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TouristStreamRef on AutoDisposeStreamProviderRef<TouristModel?> {
  /// The parameter `uid` of this provider.
  String get uid;
}

class _TouristStreamProviderElement
    extends AutoDisposeStreamProviderElement<TouristModel?>
    with TouristStreamRef {
  _TouristStreamProviderElement(super.provider);

  @override
  String get uid => (origin as TouristStreamProvider).uid;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
