.pragma library

function candidates(ic, qs, home) {
    if (!ic) return [];
    if (ic.indexOf("image://icon/") === 0) ic = ic.substring("image://icon/".length);
    if (ic.startsWith("file://") || ic.startsWith("http://") || ic.startsWith("https://")) return [ic];
    if (ic.startsWith("/")) return ["file://" + ic];

    var baseName = ic.replace(/\.(png|svg|xpm|ico)$/i, "");
    if (qs && typeof qs.iconPath === "function") {
        var resolved = qs.iconPath(ic, true) || qs.iconPath(baseName, true);
        if (resolved && resolved.length > 0) {
            return [resolved.startsWith("/") ? ("file://" + resolved) : resolved];
        }
    }

    var roots = ["/usr/share/icons/hicolor"];
    if (home) roots.push(home + "/.local/share/icons/hicolor");
    var sizes = ["256x256", "128x128", "96x96", "64x64", "48x48", "32x32", "scalable"];
    var exts = ["png", "svg", "xpm"];
    var out = [];
    var r, s, e;
    for (r = 0; r < roots.length; r++) {
        for (s = 0; s < sizes.length; s++) {
            for (e = 0; e < exts.length; e++) {
                out.push("file://" + roots[r] + "/" + sizes[s] + "/apps/" + baseName + "." + exts[e]);
            }
        }
    }
    out.push("file:///usr/share/pixmaps/" + baseName + ".png");
    out.push("file:///usr/share/pixmaps/" + baseName + ".svg");
    out.push("file:///usr/share/pixmaps/" + baseName + ".xpm");
    return out;
}
