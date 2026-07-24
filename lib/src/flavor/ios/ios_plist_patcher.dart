import 'dart:io';

/// Patches ios/Runner/Info.plist with CFBundleDisplayName and BaseURL settings.
class IosPlistPatcher {
  final String projectRoot;

  IosPlistPatcher({required this.projectRoot});

  Future<void> run() async {
    final plistFile = File('$projectRoot/ios/Runner/Info.plist');
    if (!await plistFile.exists()) {
      stderr.writeln('❌ Could not find ios/Runner/Info.plist');
      return;
    }

    String content = await plistFile.readAsString();

    content = _setOrReplaceKey(
      content,
      key: 'CFBundleDisplayName',
      value: r'$(APP_NAME)',
    );

    content = _setOrReplaceKey(content, key: 'BaseURL', value: r'$(BASE_URL)');

    await plistFile.writeAsString(content);
    print(
      '✏️  Patched ios/Runner/Info.plist (CFBundleDisplayName, BaseURL '
      'now read from active .xcconfig)',
    );
  }

  String _setOrReplaceKey(
    String plist, {
    required String key,
    required String value,
  }) {
    final existingPattern = RegExp('<key>$key</key>\\s*<string>[^<]*</string>');
    final newEntry = '<key>$key</key>\n\t<string>$value</string>';

    if (existingPattern.hasMatch(plist)) {
      return plist.replaceFirst(existingPattern, newEntry);
    }

    final closingIdx = plist.lastIndexOf('</dict>');
    if (closingIdx == -1) return plist;

    return plist.replaceRange(closingIdx, closingIdx, '\t$newEntry\n');
  }
}
