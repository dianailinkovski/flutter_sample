// Copyright 2020 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file

bool matchesQuery(String query, String sampleAttributes) {
  if (query.isEmpty) {
    return true;
  }

  var queryWords = query.toLowerCase().split(' ')
    ..removeWhere((s) => s.isEmpty);
  var attributes = sampleAttributes.toLowerCase().split(' ')
    ..removeWhere((s) => s.isEmpty);

  // Test for type filter
  // This will check whether a type parameter is present in the
  // search query, and return false if the self type mismatches
  // the query type
  for (final word in queryWords) {
    if ((word.contains('type:') && !attributes.contains(word)) ||
        (word.contains('platform:') && !attributes.contains('type:demo'))) {
      return false;
    }
  }

  // Test for exact matches
  if (attributes.contains(query)) {
    return true;
  }

  // Test for exact matches for keywords
  var matches = 0;
  for (final word in queryWords) {
    if (attributes.contains(word)) {
      matches++;
    }
    if (matches == queryWords.length) {
      return true;
    }
  }

  // Test for queries whose keywords are a substring of any attribute
  // e.g. searching "kitten tag:cats" is a match for a sample with the
  // attributes "kittens tag:cats"
  matches = 0;
  for (final attribute in attributes) {
    for (final queryWord in queryWords) {
      if (attribute.startsWith(queryWord)) {
        matches++;
      }
    }
    // Only return true if each search term was matched
    if (matches == queryWords.length) {
      return true;
    }
  }

  return false;
}

Map<String, String> parseHash(String hash) =>
    Uri.parse(hash.substring(hash.indexOf('#') + 1)).queryParameters;

String formatHash(Map<String, String> parameters) =>
    Uri().replace(queryParameters: parameters).toString();

String searchQueryFromParams(Map<String, String> params) {
  var buf = StringBuffer();
  if (params.containsKey('search')) {
    buf.write(params['search']);
  }
  if (params.containsKey('type')) {
    if (buf.isNotEmpty) buf.write(' ');
    var value = params['type'];
    if (value != null) buf.write('type:$value');
  }
  if (params.containsKey('platform')) {
    if (buf.isNotEmpty) buf.write(' ');
    var value = params['platform'];
    if (value != null) buf.write('platform:$value');
  }

  return buf.toString();
}
