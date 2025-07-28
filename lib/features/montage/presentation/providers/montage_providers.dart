import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/websocket_service.dart';
import '../../../home/domain/models/camera_model.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../domain/models/montage_profile_model.dart';

final montageProfilesProvider = StateNotifierProvider<MontageProfilesNotifier, List<MontageProfile>>((ref) {
  return MontageProfilesNotifier(ref);
});

final currentMontageProfileProvider = StateProvider<String>((ref) => 'Default');

final cameraOrderProvider = StateNotifierProvider<CameraOrderNotifier, List<String>>((ref) {
  return CameraOrderNotifier(ref);
});

final alarmStatusProvider = StreamProvider.family<AlarmStatus, String>((ref, cameraId) {
  final webSocketService = ref.watch(websocketServiceProvider);
  return webSocketService.alarmStatusStream
      .where((update) => update.cameraId == cameraId)
      .map((update) => update.status);
});

final eventCountProvider = StreamProvider.family<int, String>((ref, cameraId) {
  final webSocketService = ref.watch(websocketServiceProvider);
  int count = 0;
  return webSocketService.eventCountStream
      .where((update) => update.cameraId == cameraId)
      .map((update) => ++count);
});

class MontageProfilesNotifier extends StateNotifier<List<MontageProfile>> {
  final Ref _ref;

  MontageProfilesNotifier(this._ref) : super([]) {
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    try {
      final storageService = _ref.read(localStorageServiceProvider);
      final profiles = await storageService.getMontageProfiles();
      state = profiles;
    } catch (e) {
      state = [_createDefaultProfile()];
    }
  }

  Future<void> saveProfile(MontageProfile profile) async {
    try {
      final storageService = _ref.read(localStorageServiceProvider);
      await storageService.saveMontageProfile(profile);
      
      final existingIndex = state.indexWhere((p) => p.id == profile.id);
      if (existingIndex >= 0) {
        state = [
          ...state.sublist(0, existingIndex),
          profile,
          ...state.sublist(existingIndex + 1),
        ];
      } else {
        state = [...state, profile];
      }
    } catch (e) {
      print('Error saving montage profile: $e');
    }
  }

  Future<void> deleteProfile(String profileId) async {
    try {
      final storageService = _ref.read(localStorageServiceProvider);
      await storageService.deleteMontageProfile(profileId);
      state = state.where((p) => p.id != profileId).toList();
    } catch (e) {
      print('Error deleting montage profile: $e');
    }
  }

  /// Update camera order in current profile
  void updateCameraOrder(String profileName, int oldIndex, int newIndex) {
    final profileIndex = state.indexWhere((p) => p.name == profileName);
    if (profileIndex != -1) {
      final profile = state[profileIndex];
      final layouts = List<CameraLayout>.from(profile.cameraLayouts);
      
      if (oldIndex < layouts.length && newIndex < layouts.length) {
        final item = layouts.removeAt(oldIndex);
        layouts.insert(newIndex, item);
        
        final updatedProfile = profile.copyWith(
          cameraLayouts: layouts,
          updatedAt: DateTime.now(),
        );
        saveProfile(updatedProfile);
      }
    }
  }
  
  /// Save current layout for profile
  void saveCurrentLayout(String profileName) {
    final cameras = _ref.read(camerasProvider).value;
    if (cameras != null) {
      final layouts = cameras.asMap().entries.map((entry) {
        final index = entry.key;
        final camera = entry.value;
        
        return CameraLayout(
          cameraId: camera.id,
          x: (index % 4) * 250.0,
          y: (index ~/ 4) * 200.0,
          width: 240.0,
          height: 180.0,
          visible: true,
        );
      }).toList();
      
      final existingProfile = state.firstWhere(
        (p) => p.name == profileName,
        orElse: () => _createDefaultProfile(),
      );
      
      if (state.any((p) => p.name == profileName)) {
        final updatedProfile = existingProfile.copyWith(
          cameraLayouts: layouts,
          updatedAt: DateTime.now(),
        );
        saveProfile(updatedProfile);
      } else {
        final newProfile = MontageProfile(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: profileName,
          cameraLayouts: layouts,
          createdAt: DateTime.now(),
        );
        saveProfile(newProfile);
      }
    }
  }
  
  /// Load profile
  void loadProfile(MontageProfile profile) {
    _ref.read(currentMontageProfileProvider.notifier).state = profile.name;
  }
  
  /// Create new profile
  void createNewProfile(String profileName) {
    final newProfile = MontageProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: profileName,
      cameraLayouts: [],
      createdAt: DateTime.now(),
    );
    saveProfile(newProfile);
  }

  MontageProfile _createDefaultProfile() {
    return MontageProfile(
      id: 'default',
      name: 'Default',
      cameraLayouts: [],
      createdAt: DateTime.now(),
    );
  }
}

class CameraOrderNotifier extends StateNotifier<List<String>> {
  final Ref _ref;

  CameraOrderNotifier(this._ref) : super([]) {
    _loadCameraOrder();
  }

  Future<void> _loadCameraOrder() async {
    try {
      final storageService = _ref.read(localStorageServiceProvider);
      final order = await storageService.getCameraOrder();
      state = order;
    } catch (e) {
      state = [];
    }
  }

  Future<void> updateOrder(List<String> newOrder) async {
    state = newOrder;
    try {
      final storageService = _ref.read(localStorageServiceProvider);
      await storageService.saveCameraOrder(newOrder);
    } catch (e) {
      print('Error saving camera order: $e');
    }
  }

  void reorderCamera(int oldIndex, int newIndex) {
    final newOrder = List<String>.from(state);
    final item = newOrder.removeAt(oldIndex);
    newOrder.insert(newIndex, item);
    updateOrder(newOrder);
  }
}
