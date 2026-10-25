# Smart TV Ad Removal (LG, Roku, Samsung)

This removes ads and tracking from the smart TVs on your home network and makes their home screens faster.
It works in two layers. **Do both**:

1. **TV settings (Part 1):** turn off ads, recommendations, and viewing-tracking on each TV. This is the most
   reliable fix. It does most of the speed-up and removes the banner ads that DNS can't block.
2. **Network DNS blocking (Part 2):** a Pi-hole or AdGuard Home on your network blocks the TVs' ad and
   tracking servers, using the lists in this repo.

> **Be realistic:** no method removes 100% of home-screen ads. Some ad tiles come from the same servers as
> the TV's real content, so blocking them would break the TV. With both layers you should see far
> fewer ads, a much faster home screen, and no viewing-tracking.

---

## Part 1 — TV settings (do this first, 5 minutes per TV)

Menu names change a little between model years. If you can't find an item, search the TV's settings for the keyword.

### LG (webOS)
- **Settings → General → System → Additional Settings → Home Settings:** turn **off** *Home Promotion* and
  *Content Recommendation*. This removes the big banner at the top of the home screen.
- **Settings → General → System → Additional Settings → Advertisement:** turn **on** *Limit Ad Tracking*,
  and turn **off** *Personalized Advertising*.
- **Settings → Support → Privacy & Terms → User Agreements:** turn **off** *Viewing Information*,
  *Voice Information*, and *Interest-Based Recommendations*.
- **Settings → General → System → Additional Settings → Live Plus:** turn **off** (this is LG's viewing tracker).
- **Speed:** turn **off** *Quick Start+* if the TV feels sluggish after being on for days. It forces a clean
  boot each time. Uninstall preinstalled apps you never use.

### Samsung (Tizen)
- **Settings → Support → Terms & Privacy:** turn **off** *Viewing Information Services* (Samsung's tracker),
  *Interest-Based Advertisement*, and *Voice Recognition Services*. Under *Privacy Choices*, decline what you can.
- **Settings → General → Smart Features:** turn **off** *Autorun Smart Hub* and *Autorun Last App*. The TV
  will then boot to your input instead of an ad-filled hub. Also turn off **Samsung TV Plus** autostart.
- **Settings → General → Smart Features → Smart Hub:** turn **off** the *recommendations* in *Content Settings*.
- **Speed:** in **Settings → Support → Device Care**, run **Start Device Care** and clear the app cache.
  Uninstall unused apps. To fully clear memory, hold the remote's power button until the TV restarts.

### Roku
- **Settings → Privacy → Advertising:** turn **on** *Limit ad tracking*.
- **Settings → Privacy → Smart TV experience** (Roku TVs only): turn **off** *Use info from TV inputs*.
  This is Roku's viewing tracker.
- **Settings → Home screen:** hide the *What to Watch*, *Live TV*, *Sports*, and *Featured Free* rows/shortcuts
  (exact names vary by software version).
- **Settings → Theme → Screensavers:** turn **off**, or pick a non-Roku screensaver. Otherwise the screensaver
  can show ads.
- **Speed:** remove channels you don't use (highlight → `*` button → Remove channel). Do a restart under
  **Settings → System → Power → System restart** about once a week. To clear the cache, press
  **Home ×5, Up, Rewind ×2, Fast-forward ×2** on the remote, then wait for the restart.

---

## Part 2 — Block ad servers for every TV on the network

You need one always-on device to run the blocker. A Raspberry Pi, a NAS, or a spare PC all work. Pick **one**:

### Option A: AdGuard Home (easiest)
1. Install Docker on the always-on device. Copy the `adguard-home/` folder there and run `docker compose up -d`.
   Or install AdGuard Home natively: <https://github.com/AdguardTeam/AdGuardHome#getting-started>.
2. Open `http://<device-IP>:3000` and finish the setup wizard.
3. **Filters → DNS blocklists → Add blocklist → Add a custom list.** Add `dist/smart-tv-adguard.txt`.
4. **Filters → DNS allowlists:** add `dist/smart-tv-allowlist-adguard.txt`.
5. Optional: add `dist/smart-tv-aggressive-adguard.txt`. Read `lists/optional-aggressive.txt` first,
   because it can break things.

### Option B: Pi-hole
1. Install Pi-hole: <https://docs.pi-hole.net/main/basic-install/>.
2. **Lists:** add `dist/smart-tv-hosts.txt` (or `dist/smart-tv-adguard.txt` on Pi-hole v6+), then run
   **Tools → Update Gravity**.
3. **Domains:** add each domain in `lists/allowlist.txt` as an **exact allow**.

**How to add a list:** both tools want a URL. If this repo is **public**, use the raw GitHub URL, for example
`https://raw.githubusercontent.com/<you>/<repo>/main/dist/smart-tv-adguard.txt`. If the repo is
**private**, that URL won't work. Copy and paste the list contents into the custom-rules box
(AdGuard Home: *Filters → Custom filtering rules*; Pi-hole: *Domains*, using the domains from `lists/`).

### Point the TVs at the blocker (critical)
- **Best:** in your router's DHCP/LAN settings, set the **DNS server** to the blocker device's IP address.
  Give that device a reserved or static IP first. Then restart each TV.
- **Or per TV:** set DNS manually in each TV's network settings (Roku does not allow this, so use the router for Roku).
- **Stop TVs from bypassing it:** Roku, and some Samsung and LG models, may ignore your DNS and use Google DNS
  (`8.8.8.8`, `8.8.4.4`) directly. If your router allows it, add a firewall rule that **blocks outbound port 53
  (TCP+UDP) from the TVs to anything except the blocker**. Also block DNS-over-HTTPS to `dns.google`. Many
  routers have a "DNS hijack/redirect" or "force DNS" option that does this for you.

### Check that it works
In AdGuard Home's *Query Log* (or Pi-hole's), filter by a TV's IP address. Then browse the TV's home screen.
You should see the domains from this repo marked **Blocked**.

---

## If something breaks
- **Roku says "not connected" or channels won't load:** make sure everything in `lists/allowlist.txt` is allowed.
- **An app or the app store won't load:** open the query log, find the blocked domain from that TV at that moment,
  and allow it. If it's one of ours, please open an issue.
- **Firmware updates stopped:** you enabled the aggressive list. Temporarily allow `snu.lge.com` (LG) or
  `samsungotn.net` (Samsung), then update.

## Repo layout
| Path | What it is |
|---|---|
| `lists/lg.txt`, `lists/samsung.txt`, `lists/roku.txt` | Per-brand source lists (plain domains, commented) |
| `lists/optional-aggressive.txt` | Extra blocks with known side effects |
| `lists/allowlist.txt` | Domains that must never be blocked |
| `dist/` | Ready-to-use lists generated by `./build.sh` (hosts + adblock formats) |
| `adguard-home/docker-compose.yml` | One-command AdGuard Home install |

After editing anything in `lists/`, run `./build.sh` to regenerate `dist/`.
