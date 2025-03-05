import 'package:flutter/material.dart';

/// Service for caching and managing images in the application
class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();

  // Global image cache to persist across components
  final Map<String, ImageProvider> _globalImageCache = {};

  // Singleton pattern
  factory ImageCacheService() {
    return _instance;
  }

  ImageCacheService._internal();

  /// Get an image provider for a URL, creating it if it doesn't exist
  ImageProvider getImageProvider(String imageUrl,
      {Map<String, String>? headers}) {
    if (!_globalImageCache.containsKey(imageUrl)) {
      // Create a network image with caching enabled
      final defaultHeaders = {
        'Cache-Control': 'max-age=31536000', // Cache for a year
      };

      final mergedHeaders =
          headers != null ? {...defaultHeaders, ...headers} : defaultHeaders;

      final imageProvider = NetworkImage(
        imageUrl,
        headers: mergedHeaders,
      );

      _globalImageCache[imageUrl] = imageProvider;
      return imageProvider;
    }
    return _globalImageCache[imageUrl]!;
  }

  /// Clear the entire cache
  void clearCache() {
    _globalImageCache.clear();
  }

  /// Remove a specific image from the cache
  void removeFromCache(String imageUrl) {
    _globalImageCache.remove(imageUrl);
  }

  /// Prefetch an image into memory
  void prefetchImage(BuildContext context, String imageUrl,
      {Size? size, ImageErrorListener? onError}) {
    final imageProvider = getImageProvider(imageUrl);
    precacheImage(
      imageProvider,
      context,
      size: size,
      onError: onError,
    );
  }
}

/// LRU (Least Recently Used) cache to keep the most recently used items in memory
class LRUCache<K, V> {
  final int capacity;
  final Map<K, V> _cache = {};
  final List<K> _keys = [];

  LRUCache(this.capacity);

  V? get(K key) {
    if (!_cache.containsKey(key)) return null;

    // Move to the end of the list (most recently used)
    _keys.remove(key);
    _keys.add(key);

    return _cache[key];
  }

  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      // Update existing key
      _cache[key] = value;
      _keys.remove(key);
      _keys.add(key);
    } else {
      // Add new key
      if (_keys.length >= capacity) {
        // Remove least recently used
        final lruKey = _keys.removeAt(0);
        _cache.remove(lruKey);
      }
      _cache[key] = value;
      _keys.add(key);
    }
  }

  bool containsKey(K key) => _cache.containsKey(key);

  void clear() {
    _cache.clear();
    _keys.clear();
  }
}

/// Global LRU cache for rendered images
class RenderedImageCache {
  static final RenderedImageCache _instance = RenderedImageCache._internal();

  final LRUCache<String, Image> _cache = LRUCache<String, Image>(50);

  factory RenderedImageCache() {
    return _instance;
  }

  RenderedImageCache._internal();

  Image? get(String key) => _cache.get(key);

  void put(String key, Image value) => _cache.put(key, value);

  bool containsKey(String key) => _cache.containsKey(key);

  void clear() => _cache.clear();
}
