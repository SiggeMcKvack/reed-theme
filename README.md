# Reed

A calm, warm dark theme for [FreshRSS](https://freshrss.org), inspired by Reeder Classic.

![Reed theme](thumbs/original.png)

- Warm brown palette with an amber accent
- Centred article column without row separators, large favicons and uppercase feed names
- Grouped, Reeder-style settings pages with pill switches
- [Lucide](https://lucide.dev) icons throughout

Built and tested against FreshRSS 1.30.4.

## Installation

The theme's folder name is its ID in FreshRSS. These steps use `Reed`.

### Manual

Copy the repository contents into `p/themes/Reed` in your FreshRSS installation:

```sh
git clone --depth 1 https://github.com/SiggeMcKvack/reed-theme.git p/themes/Reed
rm -rf p/themes/Reed/.git
```

`p/` is publicly served, so remove `.git` rather than leaving it readable.

### Docker

Mount the theme as its own folder. Don't mount over `/app/www/p/themes`: that would hide FreshRSS's built-in themes, including `base-theme`, which Reed depends on.

```yaml
services:
  freshrss:
    image: linuxserver/freshrss:latest
    volumes:
      - ./config:/config
      - ./reed-theme:/app/www/p/themes/Reed
```

Adjust the container path for other images. For example, the official `freshrss/freshrss` image uses `/var/www/FreshRSS/p/themes/Reed`.

### Enable

Go to **Settings → Display → Theme** and choose **Reed**, then do a hard refresh (Cmd/Ctrl+Shift+R).

The theme is set per user. The login page uses the theme of the internal `_` user. To theme it too, set `'theme' => 'Reed'` in `data/users/_/config.php`.

## Known limitations

- Statistics chart colours are hard-coded by FreshRSS and aren't themed.
- Icons in background-loaded panels are swapped through CSS `content: url()`, which may not work in Firefox.

## License

[AGPL-3.0](LICENSE), same as FreshRSS. Lucide icons are [ISC licensed](LICENSE-lucide).
