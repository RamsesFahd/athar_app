// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationsRepositoryHash() =>
    r'ea65c4903d700050d837073c4759c504903f3e61';

/// See also [notificationsRepository].
@ProviderFor(notificationsRepository)
final notificationsRepositoryProvider =
    AutoDisposeProvider<NotificationsRepository>.internal(
  notificationsRepository,
  name: r'notificationsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationsRepositoryRef
    = AutoDisposeProviderRef<NotificationsRepository>;
String _$userNotificationsHash() => r'ace3ba5ddc49fab4ef29bd29f253fa8ad61db791';

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

/// See also [userNotifications].
@ProviderFor(userNotifications)
const userNotificationsProvider = UserNotificationsFamily();

/// See also [userNotifications].
class UserNotificationsFamily
    extends Family<AsyncValue<List<AppNotificationModel>>> {
  /// See also [userNotifications].
  const UserNotificationsFamily();

  /// See also [userNotifications].
  UserNotificationsProvider call(
    String userId,
  ) {
    return UserNotificationsProvider(
      userId,
    );
  }

  @override
  UserNotificationsProvider getProviderOverride(
    covariant UserNotificationsProvider provider,
  ) {
    return call(
      provider.userId,
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
  String? get name => r'userNotificationsProvider';
}

/// See also [userNotifications].
class UserNotificationsProvider
    extends AutoDisposeStreamProvider<List<AppNotificationModel>> {
  /// See also [userNotifications].
  UserNotificationsProvider(
    String userId,
  ) : this._internal(
          (ref) => userNotifications(
            ref as UserNotificationsRef,
            userId,
          ),
          from: userNotificationsProvider,
          name: r'userNotificationsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$userNotificationsHash,
          dependencies: UserNotificationsFamily._dependencies,
          allTransitiveDependencies:
              UserNotificationsFamily._allTransitiveDependencies,
          userId: userId,
        );

  UserNotificationsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    Stream<List<AppNotificationModel>> Function(UserNotificationsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserNotificationsProvider._internal(
        (ref) => create(ref as UserNotificationsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<AppNotificationModel>> createElement() {
    return _UserNotificationsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserNotificationsProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserNotificationsRef
    on AutoDisposeStreamProviderRef<List<AppNotificationModel>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserNotificationsProviderElement
    extends AutoDisposeStreamProviderElement<List<AppNotificationModel>>
    with UserNotificationsRef {
  _UserNotificationsProviderElement(super.provider);

  @override
  String get userId => (origin as UserNotificationsProvider).userId;
}

String _$unreadNotificationCountHash() =>
    r'8b11a657a1e29ecc4e2dbff9c74aac9b21f0aa7b';

/// See also [unreadNotificationCount].
@ProviderFor(unreadNotificationCount)
const unreadNotificationCountProvider = UnreadNotificationCountFamily();

/// See also [unreadNotificationCount].
class UnreadNotificationCountFamily extends Family<AsyncValue<int>> {
  /// See also [unreadNotificationCount].
  const UnreadNotificationCountFamily();

  /// See also [unreadNotificationCount].
  UnreadNotificationCountProvider call(
    String userId,
  ) {
    return UnreadNotificationCountProvider(
      userId,
    );
  }

  @override
  UnreadNotificationCountProvider getProviderOverride(
    covariant UnreadNotificationCountProvider provider,
  ) {
    return call(
      provider.userId,
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
  String? get name => r'unreadNotificationCountProvider';
}

/// See also [unreadNotificationCount].
class UnreadNotificationCountProvider extends AutoDisposeStreamProvider<int> {
  /// See also [unreadNotificationCount].
  UnreadNotificationCountProvider(
    String userId,
  ) : this._internal(
          (ref) => unreadNotificationCount(
            ref as UnreadNotificationCountRef,
            userId,
          ),
          from: unreadNotificationCountProvider,
          name: r'unreadNotificationCountProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$unreadNotificationCountHash,
          dependencies: UnreadNotificationCountFamily._dependencies,
          allTransitiveDependencies:
              UnreadNotificationCountFamily._allTransitiveDependencies,
          userId: userId,
        );

  UnreadNotificationCountProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    Stream<int> Function(UnreadNotificationCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UnreadNotificationCountProvider._internal(
        (ref) => create(ref as UnreadNotificationCountRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<int> createElement() {
    return _UnreadNotificationCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UnreadNotificationCountProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UnreadNotificationCountRef on AutoDisposeStreamProviderRef<int> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UnreadNotificationCountProviderElement
    extends AutoDisposeStreamProviderElement<int>
    with UnreadNotificationCountRef {
  _UnreadNotificationCountProviderElement(super.provider);

  @override
  String get userId => (origin as UnreadNotificationCountProvider).userId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
