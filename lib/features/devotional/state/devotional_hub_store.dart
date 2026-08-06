import '../../appshub/bootstrap_store.dart';
import '../models/devotional_hub_config.dart';

class DevotionalHubStore {
  final CelebrationBootstrapStore bootstrapStore;

  const DevotionalHubStore(this.bootstrapStore);

  DevotionalHubConfig get config =>
      DevotionalHubConfig.resolve(bootstrapStore.bootstrap);
}
