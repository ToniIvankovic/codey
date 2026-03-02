abstract class CacheManager {
  T? get<T>(String key);
  void set(String key, dynamic value);
  void invalidate(String key);
  void invalidateAll();
}

class CacheManagerImpl implements CacheManager {
  final Map<String, dynamic> _cache = {};

  @override
  T? get<T>(String key) => _cache[key] as T?;

  @override
  void set(String key, dynamic value) => _cache[key] = value;

  @override
  void invalidate(String key) => _cache.remove(key);

  @override
  void invalidateAll() => _cache.clear();
}
