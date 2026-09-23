# Lean Cookie Consent for Moodle

Lean Cookie Consent for Moodle is a minimal connector for the Lean Cookie Consent SaaS.
It follows the same model as the WordPress 2.0.0 minimal connector:

`Moodle -> Site Key -> bundled local runtime -> /v1/config -> /api/consent`

The administrator enters only the Site Key obtained from Lean Cookie Consent. The plugin then loads a bundled local JavaScript runtime across the Moodle site. The runtime fetches public JSON configuration from Lean Cookie Consent and records visitor consent choices through the Lean consent API.

## Scope

This plugin intentionally does very little inside Moodle:

- enable/disable;
- manual Site Key setting;
- Connected / Not configured status;
- dashboard link;
- bundled local JavaScript runtime;
- JSON configuration from `https://api.leancookieconsent.com/v1/config?site=<SITE_KEY>`;
- consent logging to `https://api.leancookieconsent.com/api/consent?site=<SITE_KEY>`.

## What it does not do

- It does not load remote executable JavaScript.
- It does not call `https://api.leancookieconsent.com/embed.js`.
- It does not expose arbitrary JavaScript, HTML or CSS fields.
- It does not create Lean accounts.
- It does not perform onboarding or account linking.
- It does not collect Moodle users, courses, plugins, themes or diagnostic inventories.
- It does not store consent logs in Moodle.

## Requirements

- Moodle 4.1 or later.
- A Lean Cookie Consent account with a site already configured.
- A valid Lean Cookie Consent Site Key.
- Browser access to `https://api.leancookieconsent.com`.
- If the Moodle site uses a Content Security Policy, `connect-src` must allow `https://api.leancookieconsent.com`.

## Installation

1. Copy the `leancookieconsent` folder into `<moodle>/local/`.
2. Log in as administrator.
3. Visit `Site administration -> Notifications` to complete installation.
4. Go to `Site administration -> Plugins -> Local plugins -> Lean Cookie Consent`.
5. Enable the plugin and paste the Site Key.
6. Save changes.

To disconnect, disable the plugin or clear the Site Key and save changes.

## Creating the Moodle release ZIP

Do not use GitHub's **Download ZIP** button for a Moodle release: GitHub names
the archive root after the repository (for example,
`local_leancookieconsent-main/`), which Moodle refuses. From a checked-out,
committed release revision run:

```bash
./tools/package-moodle-plugin.sh
```

The command creates `dist/leancookieconsent.zip` and verifies that its sole
root directory is `leancookieconsent/`, as required by Moodle's ZIP installer.

## Frontend behaviour

When enabled and configured, the plugin adds two tags to the standard HTML head:

1. A non-executable JSON configuration tag containing only the public Site Key and Lean API base URL.
2. A same-origin script tag loading `/local/leancookieconsent/assets/lean-cookie-consent.js`.

The JavaScript asset is static and does not require query parameters. The runtime reads the JSON configuration tag, fetches `/v1/config`, renders the banner and records consent choices through `/api/consent`.

When disabled or not configured, the plugin emits no runtime tag and makes no Lean API request.

## Consent gating notes

The plugin uses the earliest standard Moodle output point available:

- Moodle 4.1-4.3: legacy `local_leancookieconsent_before_standard_html_head()`.
- Moodle 4.4+: PSR-14 `core\hook\output\before_standard_head_html_generation`.

The runtime sets a default denied consent state before fetching Lean configuration. This is the earliest bootstrap available without modifying Moodle core, Boost, child themes or templates.

Technical limitation: Moodle cannot guarantee blocking of analytics or marketing scripts that are emitted before this standard head hook, hardcoded by a theme, added by another plugin earlier in the head, injected through raw additional HTML, or loaded server-side. For strong gating, configure analytics/marketing integrations to respect Consent Mode or load only after consent.

## External services

This plugin connects to the Lean Cookie Consent SaaS platform.

Configuration API:

- URL: `https://api.leancookieconsent.com/v1/config`
- When: on frontend page loads, only when the plugin is enabled and a valid Site Key is configured.
- What is sent: the configured public Site Key, plus standard browser request metadata required to return the public configuration.
- What is received: JSON configuration used by the local runtime to render the banner, preference center, policy links, categories, services and consent-mode signalling.

Consent API:

- URL: `https://api.leancookieconsent.com/api/consent`
- When: when a visitor saves, denies or accepts consent choices.
- What is sent: the configured public Site Key, selected consent categories/action, pseudonymous visitor identifier, page URL and policy/banner/evidence metadata from the SaaS configuration.
- What is received: JSON confirmation that the consent event was stored.

Service provider: Black Lotus Consulting Srl, https://leancookieconsent.com/

Privacy Policy: https://leancookieconsent.com/privacy-policy

Terms: https://leancookieconsent.com/terms

## Privacy

The Moodle plugin stores only administrator configuration in Moodle:

- enable/disable flag;
- public Site Key.

It does not store Moodle user data, course data, plugin lists, theme lists or local consent logs.

## Compatibility

- Moodle 4.1, 4.2, 4.3 through the legacy output callback.
- Moodle 4.4 and 5.x through the PSR-14 output hook.
- Boost and Boost-based themes, without theme modifications.

## License

GNU GPL v3 or later.
