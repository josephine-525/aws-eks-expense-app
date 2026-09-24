<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Expenses</title>
  <!-- favicon: avoid default /favicon.ico 403 on S3-only bucket -->
  <link rel="icon" type="image/png" href="favicon.ico" />
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />
  <style>
    :root {
      --bg: #f7f7f7;
      --surface: #ffffff;
      --text: #111111;
      --muted: #8c8c8c;
      --line: #ebebeb;
      --accent: #111111;
      --green: #07c160;
      --green-soft: #e8f8ef;
      --red: #fa5151;
      --red-soft: #fff0f0;
      --pill-bg: #f0f0f0;
      --radius: 12px;
      --radius-pill: 999px;
      font-family: "Inter", -apple-system, BlinkMacSystemFont, "PingFang SC", "Helvetica Neue", sans-serif;
      color: var(--text);
      font-size: 15px;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      min-height: 100vh;
      background: var(--bg);
      line-height: 1.45;
      -webkit-font-smoothing: antialiased;
    }
    .wrap {
      max-width: 480px;
      width: 100%;
      margin: 0 auto;
      padding: 0.75rem 1rem 2rem;
      display: flex;
      flex-direction: column;
      min-height: 100vh;
    }

    /* —— 顶部导航 —— */
    .nav-app {
      flex-shrink: 0;
      background: var(--surface);
      margin: 0 -1rem;
      padding: 0.65rem 1rem 0.5rem;
    }
    .nav-row1 {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 0.5rem;
    }
    .nav-title {
      flex-shrink: 0;
      min-width: 0;
    }
    .nav-title h1 {
      font-size: 1.125rem;
      font-weight: 600;
      letter-spacing: -0.02em;
      margin: 0;
    }
    .nav-title .sub { display: none; }
    .nav-center {
      flex: 1;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 0.35rem;
      min-width: 0;
    }
    .nav-user {
      width: 3.25rem;
      padding: 0.28rem 0.35rem;
      border: none;
      border-radius: 8px;
      background: var(--pill-bg);
      font-size: 0.75rem;
      font-weight: 500;
      color: var(--text);
      text-align: center;
    }
    .nav-user:focus {
      outline: none;
      background: #e8e8e8;
    }
    .month-nav {
      display: inline-flex;
      align-items: center;
      gap: 0;
      background: var(--pill-bg);
      border-radius: var(--radius-pill);
      padding: 1px 2px;
    }
    .month-nav button {
      width: 1.6rem;
      height: 1.6rem;
      border: none;
      border-radius: var(--radius-pill);
      background: transparent;
      color: var(--muted);
      cursor: pointer;
      font-size: 0.95rem;
      line-height: 1;
      display: grid;
      place-items: center;
    }
    .month-nav button:active { background: rgba(0, 0, 0, 0.05); }
    #monthLabel {
      min-width: 4.5rem;
      max-width: 6.5rem;
      text-align: center;
      font-size: 0.75rem;
      font-weight: 500;
      color: var(--text);
      font-variant-numeric: tabular-nums;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    .nav-right {
      flex-shrink: 0;
      display: flex;
      align-items: center;
      gap: 0.35rem;
    }
    .lang-switch {
      display: inline-flex;
      border-radius: var(--radius-pill);
      background: var(--pill-bg);
      padding: 2px;
    }
    .lang-switch button {
      margin: 0;
      padding: 0.25rem 0.45rem;
      font-size: 0.65rem;
      font-weight: 600;
      border: none;
      background: transparent;
      color: var(--muted);
      cursor: pointer;
      border-radius: var(--radius-pill);
    }
    .lang-switch button.is-active {
      color: var(--text);
      background: var(--surface);
      box-shadow: 0 1px 2px rgba(0, 0, 0, 0.06);
    }

    .bell-wrap { position: relative; }
    .bell-btn {
      position: relative;
      width: 2rem;
      height: 2rem;
      border-radius: var(--radius-pill);
      border: none;
      background: transparent;
      cursor: pointer;
      display: grid;
      place-items: center;
      font-size: 1.05rem;
      color: var(--muted);
    }
    .bell-btn:active { background: var(--pill-bg); }
    .bell-dot {
      position: absolute;
      top: 0.3rem;
      right: 0.3rem;
      width: 0.38rem;
      height: 0.38rem;
      border-radius: 50%;
      background: var(--red);
      display: none;
    }
    .bell-dot.on { display: block; }
    .bell-dot.warn { background: #f59e0b; }
    .bell-panel {
      display: none;
      position: absolute;
      right: 0;
      top: calc(100% + 0.35rem);
      width: min(18rem, calc(100vw - 2rem));
      background: var(--surface);
      border-radius: var(--radius);
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
      z-index: 80;
      padding: 0.45rem 0;
    }
    .bell-panel.open { display: block; }
    .bell-panel h3 {
      margin: 0 0.85rem 0.35rem;
      font-size: 0.62rem;
      color: var(--muted);
      font-weight: 600;
      letter-spacing: 0.05em;
    }
    .bell-msg {
      padding: 0.5rem 0.85rem;
      font-size: 0.8125rem;
      line-height: 1.45;
    }
    .bell-msg.warn { color: #b45309; }
    .bell-msg.danger { color: var(--red); }
    .bell-msg.info { color: var(--muted); }

    .nav-row2 {
      display: flex;
      justify-content: flex-end;
      gap: 0.4rem;
      margin-top: 0.55rem;
      padding-bottom: 0.15rem;
    }
    .nav-tool-btn {
      padding: 0.35rem 0.75rem;
      font-size: 0.75rem;
      font-weight: 500;
      color: var(--text);
      background: var(--pill-bg);
      border: none;
      border-radius: var(--radius-pill);
      cursor: pointer;
    }
    .nav-tool-btn:active { opacity: 0.85; }

    /* —— 核心输入区 —— */
    .input-core {
      flex-shrink: 0;
      background: var(--surface);
      margin: 0.5rem -1rem 0;
      padding: 1.25rem 1rem 1rem;
      border-radius: 0 0 16px 16px;
    }
    .amt-display-wrap {
      display: flex;
      align-items: baseline;
      justify-content: center;
      gap: 0.15rem;
      margin-bottom: 0.25rem;
    }
    .amt-currency {
      font-size: 1.5rem;
      font-weight: 500;
      color: var(--muted);
      font-variant-numeric: tabular-nums;
    }
    .amt-big {
      width: 100%;
      max-width: 11rem;
      border: none;
      background: transparent;
      font-size: 2.75rem;
      font-weight: 600;
      letter-spacing: -0.03em;
      font-variant-numeric: tabular-nums;
      text-align: center;
      color: var(--text);
      padding: 0.15rem 0;
    }
    .amt-big:focus { outline: none; }
    .amt-big::-webkit-outer-spin-button,
    .amt-big::-webkit-inner-spin-button {
      -webkit-appearance: none;
      margin: 0;
    }
    .amt-big[type="number"] { -moz-appearance: textfield; appearance: textfield; }

    .cat-strip-scroll {
      margin: 1rem -1rem 0;
      padding: 0 1rem;
      overflow-x: auto;
      -webkit-overflow-scrolling: touch;
      scrollbar-width: none;
    }
    .cat-strip-scroll::-webkit-scrollbar { display: none; }
    .cat-strip {
      display: inline-flex;
      gap: 0.4rem;
      padding-bottom: 0.15rem;
    }
    .cat-tag {
      flex-shrink: 0;
      padding: 0.4rem 0.85rem;
      font-size: 0.8125rem;
      font-weight: 500;
      border: none;
      border-radius: var(--radius-pill);
      background: var(--pill-bg);
      color: var(--text);
      cursor: pointer;
      white-space: nowrap;
    }
    .cat-tag.is-active {
      background: var(--text);
      color: #fff;
    }

    .hint-voice {
      margin: 0.85rem 0 0;
      font-size: 0.68rem;
      color: var(--muted);
      line-height: 1.45;
    }

    .entry-actions {
      display: flex;
      align-items: stretch;
      gap: 0.5rem;
      margin-top: 1rem;
      width: 100%;
      max-width: 100%;
      min-width: 0;
    }
    .btn-voice {
      flex-shrink: 0;
      padding: 0.55rem 0.85rem;
      font-size: 0.8125rem;
      font-weight: 500;
      color: var(--muted);
      background: var(--pill-bg);
      border: none;
      border-radius: var(--radius-pill);
      cursor: pointer;
    }
    .btn-voice:active { opacity: 0.88; }
    .btn-add-main {
      flex: 1;
      min-width: 0;
      max-width: 100%;
      padding: 0.65rem 1rem;
      border-radius: var(--radius-pill);
      border: none;
      background: var(--accent);
      color: #fff;
      font-size: 0.9375rem;
      font-weight: 600;
      cursor: pointer;
    }
    .btn-add-main:active { transform: scale(0.99); }
    .voice-state-inline {
      margin: 0.35rem 0 0;
      min-height: 1rem;
      font-size: 0.72rem;
      color: var(--muted);
      line-height: 1.35;
    }
    .voice-state-inline.listening { color: var(--red); font-weight: 500; }

    /* —— 底部账单区 —— */
    .ledger-section {
      flex: 0 0 auto;
      display: flex;
      flex-direction: column;
      margin-top: 0.75rem;
    }
    .month-chips-scroll {
      overflow-x: auto;
      -webkit-overflow-scrolling: touch;
      scrollbar-width: none;
      margin-bottom: 0.65rem;
    }
    .month-chips-scroll::-webkit-scrollbar { display: none; }
    .month-chips-wrap {
      display: inline-flex;
      align-items: center;
      gap: 0.35rem;
      padding: 0.15rem 0;
    }
    .month-chips {
      display: inline-flex;
      gap: 0.3rem;
    }
    .month-chip {
      flex-shrink: 0;
      padding: 0.22rem 0.55rem;
      border-radius: var(--radius-pill);
      border: none;
      background: var(--surface);
      color: var(--muted);
      font-size: 0.72rem;
      font-weight: 500;
      cursor: pointer;
      box-shadow: 0 0 0 1px var(--line);
    }
    .month-chip.is-active {
      color: var(--text);
      background: #eefcf4;
      box-shadow: 0 0 0 1px var(--green);
    }

    .ledger-summary {
      background: var(--surface);
      border-radius: var(--radius);
      padding: 1rem 1rem 0.65rem;
      text-align: center;
    }
    .hero-total {
      font-size: 1.65rem;
      font-weight: 600;
      letter-spacing: -0.03em;
      font-variant-numeric: tabular-nums;
      color: var(--text);
    }
    .hero-total.is-over { color: var(--red); }
    .hero-total.is-safe { color: var(--green); }
    .hero-meta {
      margin: 0.4rem 0 0;
      font-size: 0.75rem;
      color: var(--muted);
    }
    .budget-track {
      margin: 0.75rem 0 0;
      height: 4px;
      border-radius: var(--radius-pill);
      overflow: hidden;
      transition: background 0.2s;
    }
    .budget-track[hidden] { display: none !important; }
    .budget-track.track-safe { background: var(--green-soft); }
    .budget-track.track-over { background: var(--red-soft); }
    .budget-fill {
      height: 100%;
      border-radius: var(--radius-pill);
      width: 0%;
      transition: width 0.25s ease, background 0.2s;
    }
    .budget-fill.is-safe { background: var(--green); }
    .budget-fill.is-over { background: var(--red); }

    .section-label {
      font-size: 0.68rem;
      font-weight: 600;
      color: var(--muted);
      letter-spacing: 0.04em;
      margin: 0.75rem 0 0.25rem 0.15rem;
    }
    .list-latest-hint {
      margin: 0 0 0.2rem 0.15rem;
      font-size: 0.72rem;
      color: var(--muted);
    }

    .ledger-list-outer {
      position: relative;
      display: flex;
      flex-direction: column;
      flex: 0 0 auto;
      align-items: stretch;
    }
    .ledger-list-wrap {
      position: relative;
      height: auto;
      max-height: none;
      overflow: visible;
      border-radius: 0 0 var(--radius) var(--radius);
      background: var(--surface);
    }
    .ledger-list-wrap.is-expanded {
      max-height: min(58vh, 28rem);
      overflow: hidden;
    }
    .ledger-list-inner {
      height: auto;
      max-height: none;
      overflow: visible;
      padding: 0 1rem 0;
      -webkit-overflow-scrolling: touch;
    }
    .ledger-list-wrap.is-expanded .ledger-list-inner {
      overflow-y: auto;
      max-height: min(58vh, 28rem);
      padding-bottom: 0.5rem;
    }

    ul.list {
      list-style: none;
      padding: 0;
      margin: 0;
    }
    ul.list li.list-row {
      display: flex;
      align-items: flex-start;
      justify-content: space-between;
      gap: 0.75rem;
      padding: 0.55rem 0;
      font-size: 0.875rem;
      border-bottom: 1px solid var(--line);
    }
    ul.list li.list-row:last-child { border-bottom: none; }
    ul.list li.list-row--empty {
      justify-content: center;
      color: var(--muted);
      border: none;
      padding: 1.5rem 0;
    }
    .list-main {
      flex: 1;
      min-width: 0;
      text-align: left;
    }
    .list-cat { font-weight: 500; }
    .list-note {
      display: block;
      margin-top: 0.1rem;
      font-size: 0.78rem;
      color: var(--muted);
    }
    .list-amt {
      flex-shrink: 0;
      font-variant-numeric: tabular-nums;
      font-weight: 600;
      font-size: 0.875rem;
    }
    .list-amt .unit {
      font-size: 0.72rem;
      font-weight: 500;
      color: var(--muted);
      margin-right: 0.08rem;
    }

    .btn-toggle-list {
      width: 100%;
      flex-shrink: 0;
      margin-top: 0.25rem;
      padding: 0.5rem 0.55rem;
      font-size: 0.8125rem;
      font-weight: 500;
      color: var(--muted);
      background: var(--surface);
      border: none;
      border-radius: var(--radius-pill);
      cursor: pointer;
      box-shadow: 0 0 0 1px var(--line);
    }

    label.visually-hidden {
      position: absolute;
      width: 1px;
      height: 1px;
      padding: 0;
      margin: -1px;
      overflow: hidden;
      clip: rect(0, 0, 0, 0);
      white-space: nowrap;
      border: 0;
    }
    input, button { font: inherit; }

    dialog {
      border: none;
      border-radius: 14px;
      padding: 0;
      max-width: 22rem;
      box-shadow: 0 8px 40px rgba(0, 0, 0, 0.12);
    }
    dialog::backdrop {
      background: rgba(0, 0, 0, 0.35);
      backdrop-filter: blur(4px);
    }
    .dlg-inner { padding: 1.25rem; }
    .dlg-inner h2 {
      margin: 0 0 1rem;
      font-size: 1rem;
      font-weight: 600;
      letter-spacing: -0.02em;
    }
    .dlg-inner .field { margin-bottom: 0.85rem; }
    .dlg-inner label {
      display: block;
      font-size: 0.6875rem;
      font-weight: 500;
      color: var(--muted);
      margin-bottom: 0.3rem;
      text-transform: uppercase;
      letter-spacing: 0.04em;
    }
    .dlg-inner .inp { background: #fafafa; }
    .dlg-inner .row.toolbar {
      display: flex;
      gap: 0.5rem;
      margin-top: 1rem;
    }
    .dlg-inner button.btn {
      flex: 1;
      padding: 0.55rem;
      border-radius: var(--radius-pill);
      border: none;
      font-weight: 500;
      font-size: 0.875rem;
      cursor: pointer;
    }
    .dlg-inner button.btn.primary {
      background: var(--accent);
      color: #fff;
    }
    .dlg-inner button.btn:not(.primary) {
      background: #fafafa;
      color: var(--text);
    }

  </style>
</head>
<body>
  <div class="wrap">
    <input type="hidden" id="monthKey" value="" />
    <input type="hidden" id="cat" value="" />

    <nav class="nav-app">
      <div class="nav-row1">
        <div class="nav-title">
          <h1 data-i18n="title">Expenses</h1>
          <p class="sub" data-i18n="sub">Track spending by month; type or use voice. The bell shows budget alerts at 90% / 100%.</p>
        </div>
        <div class="nav-center">
          <input class="nav-user" id="uid" value="demo" autocomplete="username" />
          <div class="month-nav" role="group" data-i18n-aria="aria.monthNav">
            <button type="button" id="monthPrev">‹</button>
            <span id="monthLabel" aria-live="polite"></span>
            <button type="button" id="monthNext">›</button>
          </div>
        </div>
        <div class="nav-right">
          <div class="lang-switch" role="group" data-i18n-aria="aria.langSwitch">
            <button type="button" class="lang-btn" id="langEn" data-set-lang="en">EN</button>
            <button type="button" class="lang-btn" id="langZh" data-set-lang="zh">中文</button>
          </div>
          <div class="bell-wrap">
            <button type="button" class="bell-btn" id="bellBtn" aria-expanded="false" data-i18n-aria="aria.bell">
              <span aria-hidden="true">🔔</span>
              <span class="bell-dot" id="bellDot"></span>
            </button>
            <div class="bell-panel" id="bellPanel" role="region" data-i18n-aria="aria.bellPanel">
              <h3 data-i18n="bellHeading">Notifications</h3>
              <div id="bellMessages"></div>
            </div>
          </div>
        </div>
      </div>
      <div class="nav-row2">
        <button type="button" class="nav-tool-btn" id="btnCreateMonth" data-i18n="btn.monthLedgerShort">Budget</button>
        <button type="button" class="nav-tool-btn" id="btnRefresh" data-i18n="btn.refreshShort">Refresh</button>
      </div>
    </nav>

    <section class="input-core">
      <div class="amt-display-wrap">
        <span class="amt-currency">¥</span>
        <label class="visually-hidden" for="amt" data-i18n="label.amount">Amount</label>
        <input class="amt-big" id="amt" type="number" step="0.01" inputmode="decimal" placeholder="0.00" />
      </div>
      <div class="cat-strip-scroll">
        <div class="cat-strip" id="catTags" role="listbox" data-i18n-aria="aria.catTags"></div>
      </div>
      <p class="hint-voice" data-i18n="hint.voiceShort">Say the amount by voice, then tap a category.</p>
      <div class="entry-actions">
        <button type="button" class="btn-voice" id="btnVoice" data-i18n="btn.voice">Voice</button>
        <button type="button" class="btn-add-main" id="add" data-i18n="btn.addThisMonth">Add</button>
      </div>
      <p class="voice-state-inline" id="voiceState" aria-live="polite"></p>
    </section>

    <section class="ledger-section" aria-live="polite">
      <div class="month-chips-scroll">
        <div class="month-chips-wrap" id="monthChipsWrap">
          <div class="month-chips" id="monthChips" role="group" data-i18n-aria="aria.monthChips"></div>
        </div>
      </div>

      <div class="ledger-summary">
        <div class="hero-total" id="heroTotal">—</div>
        <div class="budget-track" id="budgetTrack" hidden>
          <div class="budget-fill" id="budgetFill"></div>
        </div>
        <p class="hero-meta" id="heroMeta"></p>
      </div>

      <h2 class="section-label" data-i18n="list.title">Activity</h2>
      <p class="list-latest-hint" id="listLatestHint" hidden data-i18n="listLatestHint">Showing latest entry only · tap below for all</p>

      <div class="ledger-list-outer">
        <div class="ledger-list-wrap" id="ledgerListWrap">
          <div class="ledger-list-inner">
            <ul class="list" id="list"></ul>
          </div>
        </div>
        <button type="button" class="btn-toggle-list" id="btnToggleList" hidden>View all entries</button>
      </div>
    </section>
  </div>

  <dialog id="dlgMonth">
    <div class="dlg-inner">
      <h2 data-i18n="dlg.title">Create or update month</h2>
      <div class="field">
        <label for="dlgMonthKey" data-i18n="dlg.month">Month</label>
        <input type="month" id="dlgMonthKey" class="inp" />
      </div>
      <div class="field">
        <label for="dlgBudget" data-i18n="dlg.budget">Monthly budget (for 90% / 100% alerts)</label>
        <input id="dlgBudget" class="inp" type="number" step="0.01" min="0" data-i18n-placeholder="ph.dlgBudget" placeholder="e.g. 3000" />
      </div>
      <div class="field">
        <label for="dlgTitle" data-i18n="dlg.titleField">Title (optional)</label>
        <input id="dlgTitle" class="inp" data-i18n-placeholder="ph.dlgTitle" placeholder="e.g. April 2026" />
      </div>
      <div class="row toolbar">
        <button type="button" class="btn primary" id="dlgSave" data-i18n="dlg.save">Save</button>
        <button type="button" class="btn" id="dlgCancel" data-i18n="dlg.cancel">Cancel</button>
      </div>
    </div>
  </dialog>

  <script>
    const API = "${api_base}";

    const STR = {
      en: {
        title: "Expenses",
        sub: "Track spending by month; type or use voice. The bell shows budget alerts at 90% / 100%.",
        aria: {
          langSwitch: "Language",
          bell: "Budget alerts",
          bellPanel: "Notifications",
          monthChips: "Months with data",
          monthNav: "Month",
          monthPrev: "Previous month",
          monthNext: "Next month",
          catTags: "Category",
        },
        tags: {
          ride: "Ride",
          food: "Food",
          shopping: "Shopping",
          transport: "Transport",
          groceries: "Groceries",
          entertainment: "Entertainment",
          housing: "Housing",
          medical: "Medical",
          edu: "Education",
          other: "Other",
        },
        bellHeading: "Notifications",
        label: {
          uid: "User",
          uidShort: "User",
          month: "Month",
          monthShort: "Month",
          amount: "Amount",
          category: "Category",
          note: "Note (type or speak)",
          noteFold: "Note (optional)",
        },
        btn: {
          monthLedger: "Month budget",
          monthLedgerShort: "Budget",
          refresh: "Refresh",
          refreshShort: "Refresh",
          addThisMonth: "Add entry (this month)",
          voice: "Voice input",
          expandAll: "Expand list · all {n} entries",
          collapseList: "Collapse",
        },
        list: { title: "Activity" },
        listLatestHint: "Showing latest entry only · tap below for all",
        loading: "Loading…",
        submitting: "Saving…",
        apiNetwork: "Network error — check your connection.",
        apiNotJson: "Unexpected response (not JSON).",
        apiUnknown: "Something went wrong.",
        emptyList: "No entries yet",
        dlg: {
          title: "Set month budget",
          month: "Month",
          budget: "Monthly budget (for 90% / 100% alerts)",
          titleField: "Title (optional)",
          save: "Save",
          cancel: "Cancel",
        },
        ph: {
          amountShort: "0",
          category: "Food, transport…",
          note: "Details, with whom…",
          dlgBudget: "e.g. 3000",
          dlgTitle: "e.g. April 2026",
        },
        hint: {
          voice:
            "Voice fills the amount only. After you speak, tap a category tag below. Preview text appears next to Voice until you finish.",
          voiceShort: "Say the amount by voice, then tap a category.",
        },
        period: { thisMonth: "This month", history: "Past" },
        budgetUnset: "Not set",
        chipThis: " · Now",
        heroMetaTpl: "{n} entries · {m} · {period} · Budget {bud}",
        voice: {
          noSr: "Speech recognition is not supported in this browser (try Chrome).",
          listening: "Listening…",
          error: "Voice error — try again.",
          micFail: "Could not start microphone.",
          errNotAllowed: "Mic blocked — allow microphone for this site in browser settings.",
          errNetwork: "Speech service unreachable — check connection / try Wi‑Fi (common on mobile).",
          errNoSpeech: "No speech heard — speak closer to the mic.",
          errAborted: "Voice was interrupted — tap again.",
        },
        bellOver100: "Spending exceeded 100% of budget ({total} / {cap}).",
        bell90Stacked: "Also past the 90% threshold ({total} / {cap}).",
        bell90: "Spending is above 90% of budget ({total} / {cap}).",
        bellNoBudget: "No monthly budget set. Alerts appear after you set a budget.",
        addEntryMonth: "Add entry ({m})",
      },
      zh: {
        title: "记账",
        sub: "按月份记账；支持文字与语音。铃铛会提示当月支出相对预算是否超过 90% / 100%。",
        aria: {
          langSwitch: "语言",
          bell: "预算提醒",
          bellPanel: "提醒消息",
          monthChips: "有记账的月份",
          monthNav: "月份",
          monthPrev: "上一个月",
          monthNext: "下一个月",
          catTags: "分类",
        },
        tags: {
          ride: "打车",
          food: "餐饮",
          shopping: "购物",
          transport: "交通",
          groceries: "日用",
          entertainment: "娱乐",
          housing: "居住",
          medical: "医疗",
          edu: "教育",
          other: "其他",
        },
        bellHeading: "提醒",
        label: {
          uid: "用户",
          uidShort: "用户",
          month: "查看哪个月",
          monthShort: "月份",
          amount: "金额",
          category: "分类",
          note: "备注（可打字或语音）",
          noteFold: "备注（可选）",
        },
        btn: {
          monthLedger: "月份预算",
          monthLedgerShort: "预算",
          refresh: "刷新",
          refreshShort: "刷新",
          addThisMonth: "记一笔（本月）",
          voice: "语音输入",
          expandAll: "上滑展开 · 全部 {n} 条",
          collapseList: "收起",
        },
        list: { title: "账单明细" },
        listLatestHint: "当前仅显示最新一条 · 点击下方可查看全部",
        loading: "加载中…",
        submitting: "提交中…",
        apiNetwork: "网络错误，请检查连接。",
        apiNotJson: "接口返回异常（不是 JSON）。",
        apiUnknown: "出错了。",
        emptyList: "暂无账单记录",
        dlg: {
          title: "设置当月预算",
          month: "月份",
          budget: "当月预算（元，用于 90% / 100% 提醒）",
          titleField: "标题（可选）",
          save: "保存",
          cancel: "取消",
        },
        ph: {
          amountShort: "0",
          category: "餐饮、交通…",
          note: "写了什么、和谁…",
          dlgBudget: "例如 3000",
          dlgTitle: "例如 2026 年 4 月生活账",
        },
        hint: {
          voice:
            "语音只识别金额。说完后请点击下方分类标签选择类型；识别预览会出现在「语音输入」旁，说完后自动消失。备注请说完后再打字。",
          voiceShort: "语音输入金额，点击选分类",
        },
        period: { thisMonth: "本月", history: "历史" },
        budgetUnset: "未设置",
        chipThis: " · 今",
        heroMetaTpl: "共 {n} 条 · {m} · {period} · 预算 {bud}",
        voice: {
          noSr: "当前浏览器不支持语音识别（可换 Chrome）。",
          listening: "正在听…",
          error: "语音识别出错，请重试。",
          micFail: "无法启动麦克风。",
          errNotAllowed: "麦克风被拦截 — 请在浏览器设置里允许本站使用麦克风。",
          errNetwork: "语音服务连不上 — 请检查网络或换 Wi‑Fi（手机上较常见）。",
          errNoSpeech: "没听到声音 — 请靠近麦克风再说。",
          errAborted: "识别被中断 — 请再点一次语音。",
        },
        bellOver100: "本月支出已超过预算 100%（{total} / {cap}）。",
        bell90Stacked: "同时已超过预算 90% 警戒线（{total} / {cap}）。",
        bell90: "本月支出已达预算的 90% 以上（{total} / {cap}）。",
        bellNoBudget: "尚未设置本月预算，铃铛仅在设置预算后根据支出比例提醒。",
        addEntryMonth: "记一笔（{m}）",
      },
    };

    let lang = (function () {
      try {
        const s = localStorage.getItem("expense_lang");
        if (s === "zh" || s === "en") return s;
      } catch (e) {}
      return "en";
    })();

    let lastSummary = null;
    let listExpanded = false;
    let cachedItems = [];

    function t(key) {
      const parts = key.split(".");
      let cur = STR[lang];
      for (let i = 0; i < parts.length; i++) {
        if (cur == null) return key;
        cur = cur[parts[i]];
      }
      return typeof cur === "string" ? cur : key;
    }

    function tf(key, vars) {
      let s = t(key);
      if (!vars) return s;
      Object.keys(vars).forEach(function (k) {
        s = s.split("{" + k + "}").join(String(vars[k]));
      });
      return s;
    }

    function applyI18n() {
      document.querySelectorAll("[data-i18n]").forEach(function (el) {
        el.textContent = t(el.getAttribute("data-i18n"));
      });
      document.querySelectorAll("[data-i18n-placeholder]").forEach(function (el) {
        el.setAttribute("placeholder", t(el.getAttribute("data-i18n-placeholder")));
      });
      document.querySelectorAll("[data-i18n-aria]").forEach(function (el) {
        el.setAttribute("aria-label", t(el.getAttribute("data-i18n-aria")));
      });
      var enBtn = document.getElementById("langEn");
      var zhBtn = document.getElementById("langZh");
      if (enBtn) enBtn.classList.toggle("is-active", lang === "en");
      if (zhBtn) zhBtn.classList.toggle("is-active", lang === "zh");
      document.documentElement.lang = lang === "zh" ? "zh-Hans" : "en";
      var titleEl = document.querySelector("title");
      if (titleEl) titleEl.textContent = t("title");
      var mp = document.getElementById("monthPrev");
      var mn = document.getElementById("monthNext");
      if (mp) mp.setAttribute("aria-label", t("aria.monthPrev"));
      if (mn) mn.setAttribute("aria-label", t("aria.monthNext"));
    }

    function setLang(next) {
      if (next !== "en" && next !== "zh") return;
      lang = next;
      try {
        localStorage.setItem("expense_lang", lang);
      } catch (e) {}
      applyI18n();
      if (recognition) {
        recognition.lang = lang === "zh" ? "zh-CN" : "en-US";
      }
      updateMonthDependentUi();
      renderCategoryTags();
      syncCatTagActive();
      refreshMonthChipsLabels();
      if (lastSummary) {
        updateHeroFromSummary(selectedMonth(), cachedItems.length, lastSummary);
        renderBell(lastSummary);
      }
      renderExpenseList();
    }

    document.getElementById("langEn").onclick = function () {
      setLang("en");
    };
    document.getElementById("langZh").onclick = function () {
      setLang("zh");
    };

    applyI18n();

    const TAG_KEYS = [
      "ride",
      "food",
      "shopping",
      "transport",
      "groceries",
      "entertainment",
      "housing",
      "medical",
      "edu",
      "other",
    ];

    function renderCategoryTags() {
      const root = document.getElementById("catTags");
      if (!root) return;
      root.innerHTML = "";
      TAG_KEYS.forEach(function (key) {
        const b = document.createElement("button");
        b.type = "button";
        b.className = "cat-tag";
        b.setAttribute("role", "option");
        b.dataset.tagKey = key;
        b.textContent = t("tags." + key);
        b.onclick = function () {
          document.getElementById("cat").value = t("tags." + key);
          syncCatTagActive();
        };
        root.appendChild(b);
      });
      syncCatTagActive();
    }

    function syncCatTagActive() {
      const inp = document.getElementById("cat");
      if (!inp) return;
      const v = inp.value.trim();
      document.querySelectorAll(".cat-tag").forEach(function (btn) {
        const key = btn.dataset.tagKey;
        btn.classList.toggle("is-active", !!key && t("tags." + key) === v);
      });
    }

    function tagLabelInLang(tagKey, lng) {
      const pack = STR[lng];
      if (!pack || !pack.tags) return "";
      return pack.tags[tagKey] || "";
    }

    function matchOneCategoryString(u0) {
      const u = (u0 || "").trim();
      if (!u) return null;
      const lower = u.toLowerCase();
      let i;
      let key;
      for (i = 0; i < TAG_KEYS.length; i++) {
        key = TAG_KEYS[i];
        const enL = tagLabelInLang(key, "en");
        const zhL = tagLabelInLang(key, "zh");
        if (u === enL || u === zhL) return key;
      }
      for (i = 0; i < TAG_KEYS.length; i++) {
        key = TAG_KEYS[i];
        const enL = tagLabelInLang(key, "en");
        const zhL = tagLabelInLang(key, "zh");
        if (enL && lower === enL.toLowerCase()) return key;
        if (zhL && u === zhL) return key;
      }
      for (i = 0; i < TAG_KEYS.length; i++) {
        key = TAG_KEYS[i];
        const zhL = tagLabelInLang(key, "zh");
        const enL = tagLabelInLang(key, "en");
        if (zhL && zhL.length >= 2 && u.indexOf(zhL) !== -1) return key;
        if (enL && enL.length >= 2 && lower.indexOf(enL.toLowerCase()) !== -1) return key;
      }
      const ALIAS = {
        "打车": "ride",
        "出租车": "ride",
        "滴滴": "ride",
        "出行": "transport",
        "地铁": "transport",
        "公交": "transport",
        "吃饭": "food",
        "午饭": "food",
        "晚饭": "food",
        "早餐": "food",
        "外卖": "food",
        "咖啡": "food",
        "餐饮": "food",
        "食堂": "food",
        "超市": "groceries",
        "菜店": "groceries",
        "电影": "entertainment",
        "游戏": "entertainment",
        "房租": "housing",
        "水电": "housing",
        "物业": "housing",
        "医院": "medical",
        "药": "medical",
        "挂号": "medical",
        "书": "edu",
        "课": "edu",
        "学费": "edu",
        "taxi": "ride",
        "uber": "ride",
        "meal": "food",
        "lunch": "food",
        "dinner": "food",
        "grocery": "groceries",
        "rent": "housing",
      };
      let k;
      for (k in ALIAS) {
        if (!Object.prototype.hasOwnProperty.call(ALIAS, k)) continue;
        if (u.indexOf(k) !== -1 || lower.indexOf(String(k).toLowerCase()) !== -1) return ALIAS[k];
      }
      return null;
    }

    function matchCategoryToTagKey(raw) {
      const base = (raw || "").trim();
      if (!base) return null;
      const variants = [];
      const push = function (s) {
        const v = (s || "").trim();
        if (v && variants.indexOf(v) === -1) variants.push(v);
      };
      push(base);
      push(base.replace(/^[\d.+\s¥￥,，、]+/i, ""));
      push(base.replace(/^[\d.+\s¥￥,，、元块块钱]+/i, ""));
      base.split(/[\s,，、]+/).forEach(function (p) {
        push(p);
        push(p.replace(/^[\d.+\s¥￥,，、元块块钱]+/i, ""));
      });
      let vi;
      for (vi = 0; vi < variants.length; vi++) {
        const hit = matchOneCategoryString(variants[vi]);
        if (hit) return hit;
      }
      return null;
    }

    function displayCategoryLabel(stored) {
      const s = (stored || "").trim();
      if (!s) return "";
      let i;
      for (i = 0; i < TAG_KEYS.length; i++) {
        const key = TAG_KEYS[i];
        if (s === tagLabelInLang(key, "en") || s === tagLabelInLang(key, "zh")) {
          return t("tags." + key);
        }
      }
      const k = matchCategoryToTagKey(s);
      if (k) return t("tags." + k);
      return s;
    }

    function refreshMonthChipsLabels() {
      const nowKey = currentMonthKey();
      document.querySelectorAll(".month-chip").forEach(function (btn) {
        const k = btn.dataset.month;
        if (!k) return;
        btn.textContent = k === nowKey ? k + t("chipThis") : k;
      });
    }

    function applyCanonicalCategory(raw) {
      const merged = (raw || "").trim();
      if (!merged) {
        syncCatTagActive();
        return;
      }
      const hit = matchCategoryToTagKey(merged);
      if (hit) document.getElementById("cat").value = t("tags." + hit);
      else document.getElementById("cat").value = merged;
      syncCatTagActive();
    }

    function updateListPanelExpandClass() {
      const wrap = document.getElementById("ledgerListWrap");
      if (!wrap) return;
      const n = cachedItems.length;
      if (n <= 1) {
        wrap.classList.remove("is-expanded");
        return;
      }
      wrap.classList.toggle("is-expanded", listExpanded);
    }

    renderCategoryTags();
    (function () {
      const ce = document.getElementById("cat");
      if (ce && !ce.value.trim()) ce.value = t("tags.food");
    })();
    syncCatTagActive();

    function currentMonthKey() {
      const d = new Date();
      const y = d.getFullYear();
      const m = String(d.getMonth() + 1).padStart(2, "0");
      return y + "-" + m;
    }

    function uid() {
      return document.getElementById("uid").value.trim() || "demo";
    }

    async function fetchJson(url, init) {
      let r;
      try {
        r = await fetch(url, init);
      } catch (e) {
        throw new Error(t("apiNetwork"));
      }
      const text = await r.text();
      let j = {};
      if (text) {
        try {
          j = JSON.parse(text);
        } catch (e) {
          throw new Error(
            t("apiNotJson") + " (HTTP " + r.status + "): " + text.replace(/\s+/g, " ").slice(0, 100)
          );
        }
      }
      if (!r.ok) {
        const detail = j && (j.message || j.error);
        throw new Error(detail ? String(detail) : "HTTP " + r.status);
      }
      return j;
    }

    function showApiError(e) {
      console.error(e);
      const msg = e && e.message ? e.message : t("apiUnknown");
      document.getElementById("heroMeta").textContent = msg;
      const totalEl = document.getElementById("heroTotal");
      if (totalEl) {
        totalEl.textContent = "—";
        totalEl.classList.remove("is-over", "is-safe");
      }
      cachedItems = [];
      renderExpenseList();
    }

    function selectedMonth() {
      const inp = document.getElementById("monthKey");
      return (inp && inp.value) || currentMonthKey();
    }

    function formatMonthLabelDisplay(key) {
      const parts = key.split("-");
      if (parts.length !== 2) return key;
      const y = parseInt(parts[0], 10);
      const mo = parseInt(parts[1], 10);
      if (Number.isNaN(y) || Number.isNaN(mo)) return key;
      const d = new Date(y, mo - 1, 1);
      return d.toLocaleDateString(lang === "zh" ? "zh-CN" : "en-US", { year: "numeric", month: "short" });
    }

    function syncMonthLabel() {
      const el = document.getElementById("monthLabel");
      if (el) el.textContent = formatMonthLabelDisplay(selectedMonth());
    }

    function shiftMonth(delta) {
      const k = selectedMonth();
      const parts = k.split("-");
      if (parts.length !== 2) return;
      const y = parseInt(parts[0], 10);
      const mo = parseInt(parts[1], 10);
      if (Number.isNaN(y) || Number.isNaN(mo)) return;
      const d = new Date(y, mo - 1 + delta, 1);
      const nk = d.getFullYear() + "-" + String(d.getMonth() + 1).padStart(2, "0");
      document.getElementById("monthKey").value = nk;
      refresh();
    }

    let listening = false;
    let recognition = null;

    const CN_DIGIT = { 零: 0, 一: 1, 二: 2, 两: 2, 三: 3, 四: 4, 五: 5, 六: 6, 七: 7, 八: 8, 九: 9 };

    /** 从句首解析简单中文金额，如 五十→50、十五→15、十→10、八→8；失败返回 null */
    function parseChineseAmountPrefix(s) {
      const t = s.replace(/\s+/g, "");
      if (!t.length) return null;
      if (t.startsWith("一百")) return { value: 100, consumed: 2 };
      if (t.startsWith("两百") || t.startsWith("二百")) return { value: 200, consumed: 2 };
      const mTeen = t.match(/^十([一二两三四五六七八九])/);
      if (mTeen) return { value: 10 + CN_DIGIT[mTeen[1]], consumed: mTeen[0].length };
      const mTens = t.match(/^([一二两三四五六七八九]?)十([一二三四五六七八九]?)/);
      if (mTens) {
        const tens = mTens[1] ? CN_DIGIT[mTens[1]] : 1;
        const ones = mTens[2] ? CN_DIGIT[mTens[2]] : 0;
        return { value: tens * 10 + ones, consumed: mTens[0].length };
      }
      const mOne = t.match(/^([一二两三四五六七八九])/);
      if (mOne) return { value: CN_DIGIT[mOne[1]], consumed: 1 };
      return null;
    }

    /** 语音只写入金额；分类由用户点击标签选择（不把识别结果里的文字写进分类）。 */
    function applyVoiceTranscript(raw) {
      const amtEl = document.getElementById("amt");
      const line = (raw || "").trim();
      if (!line) return;

      let amount = null;
      let rest = line.replace(/\s+/g, " ").trim();

      const mNum = rest.match(/(\d+(?:\.\d+)?)/);
      if (mNum) {
        amount = parseFloat(mNum[1]);
      } else {
        const compact = rest.replace(/\s+/g, "");
        const cn = parseChineseAmountPrefix(compact);
        if (cn) amount = cn.value;
      }

      if (amount != null && !Number.isNaN(amount)) {
        amtEl.value = Number(amount).toFixed(2);
      }
      syncCatTagActive();
    }

    function setupVoice() {
      const SR = window.SpeechRecognition || window.webkitSpeechRecognition;
      const el = document.getElementById("voiceState");
      if (!SR) {
        el.textContent = t("voice.noSr");
        document.getElementById("btnVoice").disabled = true;
        return;
      }
      recognition = new SR();
      recognition.lang = lang === "zh" ? "zh-CN" : "en-US";
      recognition.interimResults = !/Android/i.test(navigator.userAgent || "");
      recognition.continuous = false;
      recognition.maxAlternatives = 1;

      recognition.onresult = (ev) => {
        let preview = "";
        for (let i = 0; i < ev.results.length; i++) {
          preview += ev.results[i][0].transcript;
        }
        preview = preview.trim();
        if (preview) el.textContent = preview;
        else if (listening) el.textContent = t("voice.listening");

        for (let i = ev.resultIndex; i < ev.results.length; i++) {
          if (!ev.results[i].isFinal) continue;
          const text = ev.results[i][0].transcript.trim();
          if (text) applyVoiceTranscript(text);
        }
      };
      recognition.onerror = (ev) => {
        listening = false;
        const code = ev && ev.error ? String(ev.error) : "";
        let msg = t("voice.error");
        if (code === "not-allowed") msg = t("voice.errNotAllowed");
        else if (code === "network") msg = t("voice.errNetwork");
        else if (code === "no-speech") msg = t("voice.errNoSpeech");
        else if (code === "aborted") msg = t("voice.errAborted");
        el.textContent = msg;
        el.classList.remove("listening");
      };
      recognition.onend = () => {
        listening = false;
        el.textContent = "";
        el.classList.remove("listening");
      };
    }

    document.getElementById("btnVoice").onclick = () => {
      if (!recognition) return;
      const el = document.getElementById("voiceState");
      if (listening) {
        try { recognition.stop(); } catch (e) {}
        return;
      }
      listening = true;
      el.textContent = t("voice.listening");
      el.classList.add("listening");
      try {
        recognition.start();
      } catch (e) {
        listening = false;
        el.textContent = t("voice.micFail");
        el.classList.remove("listening");
      }
    };

    let lastNotifications = [];

    function localizedBellText(n, summary) {
      const code = n.code || "";
      const total = Number(summary.total).toFixed(2);
      const cap = Number(summary.budget_cap).toFixed(2);
      if (code === "over100") return tf("bellOver100", { total: total, cap: cap });
      if (code === "over90_stacked") return tf("bell90Stacked", { total: total, cap: cap });
      if (code === "over90") return tf("bell90", { total: total, cap: cap });
      if (code === "no_budget") return t("bellNoBudget");
      return n.text || "";
    }

    function renderBell(summary) {
      const panel = document.getElementById("bellPanel");
      const msgs = document.getElementById("bellMessages");
      const dot = document.getElementById("bellDot");
      msgs.innerHTML = "";
      const list = (summary && summary.notifications) ? summary.notifications : [];
      lastNotifications = list;

      let showDot = false;
      let hasDanger = false;
      let hasWarn = false;
      list.forEach((n) => {
        const div = document.createElement("div");
        div.className = "bell-msg " + (n.level || "info");
        div.textContent = localizedBellText(n, summary);
        msgs.appendChild(div);
        if (n.level === "danger") { showDot = true; hasDanger = true; }
        if (n.level === "warn") { showDot = true; hasWarn = true; }
      });
      dot.classList.toggle("on", showDot);
      dot.classList.toggle("warn", showDot && hasWarn && !hasDanger);
    }

    function toggleBell(open) {
      const panel = document.getElementById("bellPanel");
      const btn = document.getElementById("bellBtn");
      const want = open != null ? open : !panel.classList.contains("open");
      panel.classList.toggle("open", want);
      btn.setAttribute("aria-expanded", want ? "true" : "false");
    }

    document.getElementById("bellBtn").onclick = (e) => {
      e.stopPropagation();
      toggleBell();
    };
    document.getElementById("bellPanel").addEventListener("click", (e) => e.stopPropagation());
    document.addEventListener("click", () => toggleBell(false));

    function updateMonthDependentUi() {
      syncMonthLabel();
      const m = selectedMonth();
      const nowK = currentMonthKey();
      const addBtn = document.getElementById("add");
      if (addBtn) {
        addBtn.textContent = m === nowK ? t("btn.addThisMonth") : tf("addEntryMonth", { m: m });
      }
      document.querySelectorAll(".month-chip").forEach((btn) => {
        btn.classList.toggle("is-active", btn.dataset.month === m);
      });
    }

    async function loadMonths() {
      const j = await fetchJson(API + "/months?user_id=" + encodeURIComponent(uid()));
      const inp = document.getElementById("monthKey");
      const cur = inp.value || currentMonthKey();
      const keys = new Set((j.months || []).map((x) => x.month_key));
      const nowKey = currentMonthKey();
      if (!keys.has(nowKey)) keys.add(nowKey);
      const sorted = Array.from(keys).sort().reverse();

      if (sorted.includes(cur) || /^\d{4}-\d{2}$/.test(cur)) inp.value = cur;
      else inp.value = nowKey;

      const chipRoot = document.getElementById("monthChips");
      chipRoot.innerHTML = "";
      sorted.forEach((k) => {
        const b = document.createElement("button");
        b.type = "button";
        b.className = "month-chip";
        b.dataset.month = k;
        b.textContent = k === nowKey ? k + t("chipThis") : k;
        b.onclick = () => {
          inp.value = k;
          refresh();
        };
        chipRoot.appendChild(b);
      });
      updateMonthDependentUi();
      refreshMonthChipsLabels();
    }

    async function loadSummary() {
      const m = selectedMonth();
      const s = await fetchJson(
        API + "/summary?user_id=" + encodeURIComponent(uid()) + "&month=" + encodeURIComponent(m)
      );
      renderBell(s);
      return s;
    }

    function setHeroLoading() {
      const totalEl = document.getElementById("heroTotal");
      totalEl.textContent = "—";
      totalEl.classList.remove("is-over", "is-safe");
      document.getElementById("heroMeta").textContent = t("loading");
      const track = document.getElementById("budgetTrack");
      const fill = document.getElementById("budgetFill");
      track.hidden = true;
      fill.style.width = "0%";
      fill.classList.remove("is-over", "is-safe");
      track.classList.remove("track-over", "track-safe");
    }

    function updateHeroFromSummary(m, n, s) {
      const totalEl = document.getElementById("heroTotal");
      const metaEl = document.getElementById("heroMeta");
      const track = document.getElementById("budgetTrack");
      const fill = document.getElementById("budgetFill");
      const total = s.total != null ? Number(s.total) : 0;
      const cap = s.budget_cap != null ? Number(s.budget_cap) : 0;
      const nowK = currentMonthKey();
      const period = m === nowK ? t("period.thisMonth") : t("period.history");
      const bud = cap > 0 ? "¥" + cap.toFixed(2) : t("budgetUnset");

      totalEl.textContent = "¥" + total.toFixed(2);
      totalEl.classList.remove("is-over", "is-safe");
      if (cap > 0) {
        if (total > cap) totalEl.classList.add("is-over");
        else totalEl.classList.add("is-safe");
      }

      metaEl.textContent = tf("heroMetaTpl", { n: n, m: m, period: period, bud: bud });

      fill.classList.remove("is-over", "is-safe");
      track.classList.remove("track-over", "track-safe");
      if (cap <= 0) {
        track.hidden = true;
        fill.style.width = "0%";
      } else {
        track.hidden = false;
        const ratio = total / cap;
        const pct = Math.min(100, ratio * 100);
        fill.style.width = pct + "%";
        if (total > cap) {
          fill.classList.add("is-over");
          track.classList.add("track-over");
        } else {
          fill.classList.add("is-safe");
          track.classList.add("track-safe");
        }
      }
    }

    function appendExpenseRow(ul, it) {
      const li = document.createElement("li");
      li.className = "list-row";
      const cat = escapeHtml(displayCategoryLabel(it.category || ""));
      const noteHtml = it.note
        ? '<span class="list-note">' + escapeHtml(it.note) + "</span>"
        : "";
      li.innerHTML =
        '<div class="list-main"><span class="list-cat">' +
        cat +
        "</span>" +
        noteHtml +
        '</div><span class="list-amt"><span class="unit">¥</span>' +
        Number(it.amount).toFixed(2) +
        "</span>";
      ul.appendChild(li);
    }

    function renderExpenseList() {
      const ul = document.getElementById("list");
      const btn = document.getElementById("btnToggleList");
      const hint = document.getElementById("listLatestHint");
      ul.innerHTML = "";
      const items = cachedItems;
      const n = items.length;
      if (n === 0) {
        hint.hidden = true;
        btn.hidden = true;
        const empty = document.createElement("li");
        empty.className = "list-row list-row--empty";
        empty.textContent = t("emptyList");
        ul.appendChild(empty);
        updateListPanelExpandClass();
        return;
      }
      let toShow;
      if (listExpanded || n <= 1) {
        toShow = items;
        hint.hidden = true;
        btn.hidden = n <= 1;
        btn.textContent = n > 1 ? t("btn.collapseList") : "";
      } else {
        toShow = [items[n - 1]];
        hint.hidden = false;
        btn.hidden = false;
        btn.textContent = tf("btn.expandAll", { n: n });
      }
      toShow.forEach((it) => appendExpenseRow(ul, it));
      updateListPanelExpandClass();
    }

    document.getElementById("btnToggleList").onclick = () => {
      listExpanded = !listExpanded;
      renderExpenseList();
    };

    async function refresh() {
      listExpanded = false;
      updateMonthDependentUi();
      setHeroLoading();
      const m = selectedMonth();
      try {
        const j = await fetchJson(
          API + "/expenses?user_id=" + encodeURIComponent(uid()) + "&month=" + encodeURIComponent(m)
        );
        cachedItems = j.items || [];
        const s = await loadSummary();
        lastSummary = s;
        updateHeroFromSummary(m, cachedItems.length, s);
        renderExpenseList();
        updateListPanelExpandClass();
      } catch (e) {
        showApiError(e);
      }
    }

    function escapeHtml(s) {
      const d = document.createElement("div");
      d.textContent = s;
      return d.innerHTML;
    }

    document.getElementById("monthPrev").onclick = function () {
      shiftMonth(-1);
    };
    document.getElementById("monthNext").onclick = function () {
      shiftMonth(1);
    };
    document.getElementById("uid").onchange = async () => {
      try {
        await loadMonths();
        await refresh();
      } catch (e) {
        showApiError(e);
      }
    };

    document.getElementById("add").onclick = async () => {
      const m = selectedMonth();
      const body = {
        user_id: uid(),
        month_key: m,
        amount: parseFloat(document.getElementById("amt").value) || 0,
        category: document.getElementById("cat").value || "uncategorized",
        note: "",
      };
      document.getElementById("heroMeta").textContent = t("submitting");
      try {
        await fetchJson(API + "/expenses", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(body),
        });
      } catch (e) {
        document.getElementById("heroMeta").textContent = e.message || t("apiUnknown");
        return;
      }
      document.getElementById("amt").value = "";
      try {
        await loadMonths();
        await refresh();
      } catch (e) {
        showApiError(e);
      }
    };

    document.getElementById("btnRefresh").onclick = async () => {
      try {
        await loadMonths();
        await refresh();
      } catch (e) {
        showApiError(e);
      }
    };

    const dlg = document.getElementById("dlgMonth");
    document.getElementById("btnCreateMonth").onclick = () => {
      document.getElementById("dlgMonthKey").value = selectedMonth();
      document.getElementById("dlgBudget").value = "";
      document.getElementById("dlgTitle").value = "";
      dlg.showModal();
    };
    document.getElementById("dlgCancel").onclick = () => dlg.close();
    document.getElementById("dlgSave").onclick = async () => {
      const mk = document.getElementById("dlgMonthKey").value;
      if (!mk || mk.length < 7) return;
      const budget = parseFloat(document.getElementById("dlgBudget").value);
      try {
        await fetchJson(API + "/months", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            user_id: uid(),
            month_key: mk,
            budget_cap: isNaN(budget) ? 0 : budget,
            title: document.getElementById("dlgTitle").value || "",
          }),
        });
      } catch (e) {
        document.getElementById("heroMeta").textContent = e.message || t("apiUnknown");
        return;
      }
      dlg.close();
      document.getElementById("monthKey").value = mk;
      try {
        await loadMonths();
        await refresh();
      } catch (e) {
        showApiError(e);
      }
    };

    (async function init() {
      setupVoice();
      document.getElementById("monthKey").value = currentMonthKey();
      syncMonthLabel();
      try {
        await loadMonths();
        await refresh();
      } catch (e) {
        showApiError(e);
      }
    })();
  </script>
</body>
</html>
