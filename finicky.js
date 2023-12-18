module.exports = {
  defaultBrowser: "Safari",
  options: {
    hideIcon: true
  },
  handlers: [
    {
      match: finicky.matchHostnames([
        "localhost",
        "127.0.0.1",
        /(docs|sheets|drive)\.google\.com/,
        /forms\.gle/,
        /bamboohr\.com/,
        /breezy\.hr/,
        /expensify\.com/,
        /.*figma\.com/,
        /.*newrelic\.com/,
        /.*datadoghq\.com/,
        /.*miro\.com/,
        /.*easyretro\.io/,
        /.*remo\.co/,
        /.*getguru\.com/,
        /.*37signals\.com/,
        /.*basecamp\.com/,
        /.*latticehq\.com/,
        /.*sentry\.io/,
        /.*knowyourteam\.com/,
        /.*heroku\.com/,
        /.*brex\.com/,
        /.*circleci\.com/,
        /.*datadog.*\.com/,
        /.*zipline.*/,
        /.*loom.com/,
        /.*slack.com/,
        /.*browserstack.com/,
        /.*launchdarkly.com/,
        /.*leapsome.com/,
        /.*fathom.video/,
      ]),
      browser: "Google Chrome"
    },
    {
      match: /retailzipline/,
      browser: "Google Chrome"
    },
    {
      match: ({ keys }) => keys.option,
      browser: "Google Chrome"
    }
  ]
};
