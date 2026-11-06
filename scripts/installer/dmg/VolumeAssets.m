#import <AppKit/AppKit.h>
#import <CoreServices/CoreServices.h>

static void fail(NSString *message) {
    fprintf(stderr, "%s\n", message.UTF8String);
    exit(1);
}

static void text(NSString *value, CGFloat x, CGFloat top, CGFloat width,
                 CGFloat size, NSColor *color, NSFontWeight weight, BOOL centered) {
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.alignment = centered ? NSTextAlignmentCenter : NSTextAlignmentLeft;
    CGFloat height = MAX(28, size * 1.4);
    [value drawInRect:NSMakeRect(x, 650 - top - height, width, height) withAttributes:@{
        NSFontAttributeName: [NSFont systemFontOfSize:size weight:weight],
        NSForegroundColorAttributeName: color,
        NSParagraphStyleAttributeName: style
    }];
}

static void render(NSString *output) {
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc]
        initWithBitmapDataPlanes:NULL pixelsWide:800 pixelsHigh:650
        bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO
        colorSpaceName:NSDeviceRGBColorSpace bytesPerRow:0 bitsPerPixel:0];
    bitmap.size = NSMakeSize(800, 650);
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmap];
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:context];
    NSColor *ink = [NSColor colorWithSRGBRed:.14 green:.19 blue:.27 alpha:1];
    NSColor *muted = [NSColor colorWithSRGBRed:.38 green:.44 blue:.53 alpha:1];
    NSColor *blue = [NSColor colorWithSRGBRed:.22 green:.37 blue:.57 alpha:1];
    [[NSColor colorWithSRGBRed:.96 green:.974 blue:.99 alpha:1] setFill];
    NSRectFill(NSMakeRect(0, 0, 800, 650));
    text(@"SceneHush", 0, 24, 800, 32, ink, NSFontWeightSemibold, YES);
    text(@"Drag to install  ·  拖入以安装  ·  ドラッグしてインストール", 0, 72, 800, 14, muted, NSFontWeightRegular, YES);

    [blue setStroke];
    NSBezierPath *arrow = [NSBezierPath bezierPath];
    arrow.lineWidth = 3;
    arrow.lineCapStyle = NSLineCapStyleRound;
    [arrow moveToPoint:NSMakePoint(365, 650 - 165)];
    [arrow lineToPoint:NSMakePoint(435, 650 - 165)];
    [arrow moveToPoint:NSMakePoint(423, 650 - 153)];
    [arrow lineToPoint:NSMakePoint(435, 650 - 165)];
    [arrow lineToPoint:NSMakePoint(423, 650 - 177)];
    [arrow stroke];

    NSArray<NSArray<NSString *> *> *rows = @[
        @[@"1  Drag into Applications. Then open SceneHush from Applications.",
          @"2  Blocked? Choose Done, then Settings → Privacy & Security → Open Anyway.",
          @"3  Reopen SceneHush and follow the introduction."],
        @[@"1  拖入 Applications，再从「应用程序」打开 SceneHush。",
          @"2  如被拦截，点「完成」；系统设置 → 隐私与安全性 → 仍要打开。",
          @"3  重新打开 SceneHush，跟随 App 使用引导。"],
        @[@"1  Applications にドラッグし、アプリケーションから開きます。",
          @"2  ブロック時は「完了」→ システム設定 → プライバシーとセキュリティ → このまま開く。",
          @"3  SceneHush をもう一度開き、アプリのガイドに従います。"]
    ];
    for (NSUInteger language = 0; language < rows.count; language++) {
        for (NSUInteger line = 0; line < rows[language].count; line++) {
            text(rows[language][line], 50, 270 + language * 80 + line * 21,
                 700, line == 0 ? 14 : 13, line == 0 ? ink : muted,
                 line == 0 ? NSFontWeightMedium : NSFontWeightRegular, NO);
        }
    }
    [NSGraphicsContext restoreGraphicsState];
    NSData *png = [bitmap representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
    if (![png writeToFile:output atomically:YES]) fail(@"Could not write disk image background");
}

static void verify(NSURL *root, NSDictionary *values) {
    NSError *error = nil;
    BOOL stale = NO;
    NSURL *expected = [root URLByAppendingPathComponent:@".background/background.png"];
    NSImage *background = [[NSImage alloc] initWithContentsOfURL:expected];
    if (!background || !NSEqualSizes(background.size, NSMakeSize(800, 650)))
        fail(@"Background must have an 800 × 650 point logical size");
    NSURL *resolved = [NSURL URLByResolvingBookmarkData:values[@"bookmark"]
        options:NSURLBookmarkResolutionWithoutUI | NSURLBookmarkResolutionWithoutMounting
        relativeToURL:nil bookmarkDataIsStale:&stale error:&error];
    // A bookmark can resolve to a file-reference URL whose path is not a POSIX path.
    NSURL *resolvedPathURL = resolved.filePathURL;
    if (!resolvedPathURL || ![resolvedPathURL.path.stringByResolvingSymlinksInPath
            isEqualToString:expected.path.stringByResolvingSymlinksInPath]) {
        fail([NSString stringWithFormat:
            @"Background bookmark does not resolve inside this mounted volume\n"
             "  expected: %@\n  resolved URL: %@\n  raw path: %@\n"
             "  file-reference URL: %@\n  file path: %@\n  stale: %@\n  error: %@ (%ld): %@",
            expected.path, resolved.absoluteString ?: @"<nil>", resolved.path ?: @"<nil>",
            [resolved isFileReferenceURL] ? @"yes" : @"no", resolvedPathURL.path ?: @"<nil>",
            stale ? @"yes" : @"no",
            error.domain ?: @"<none>", (long)error.code, error.localizedDescription ?: @"<none>"]);
    }
    NSData *aliasData = values[@"alias"];
    Handle handle = NewHandle(aliasData.length);
    if (!handle) fail(@"Could not allocate alias handle");
    memcpy(*handle, aliasData.bytes, aliasData.length);
    FSRef target;
    Boolean changed = false;
    OSErr status = FSResolveAliasWithMountFlags(NULL, (AliasHandle)handle, &target, &changed, kResolveAliasFileNoUI);
    DisposeHandle(handle);
    UInt8 path[PATH_MAX];
    OSStatus pathStatus = status == noErr ? FSRefMakePath(&target, path, sizeof(path)) : status;
    NSString *aliasPath = pathStatus == noErr ? @((char *)path) : @"<nil>";
    if (pathStatus != noErr || ![aliasPath.stringByResolvingSymlinksInPath
            isEqualToString:expected.path.stringByResolvingSymlinksInPath]) {
        fail([NSString stringWithFormat:
            @"Background alias does not resolve inside this mounted volume\n"
             "  expected: %@\n  resolved: %@\n  resolve status: %d\n  path status: %d",
            expected.path, aliasPath, status, (int)pathStatus]);
    }
    puts("Background alias and bookmark resolve inside the mounted volume");
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc == 3 && strcmp(argv[1], "render") == 0) {
            render(@(argv[2]));
            return 0;
        }
        if (argc != 4) fail(@"Usage: VolumeAssets render output.png | verify volume metadata.plist");
        NSURL *root = [NSURL fileURLWithPath:@(argv[2]) isDirectory:YES];
        if (strcmp(argv[1], "verify") == 0) {
            verify(root, [NSDictionary dictionaryWithContentsOfFile:@(argv[3])]);
        } else {
            fail(@"Unknown VolumeAssets action");
        }
    }
    return 0;
}
