# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Vendored manually (not via `bin/importmap pin`) — ECharts' npm package
# resolves through a deep tree of zrender submodules that jspm.io's CDN
# pinning can't statically follow. echarts.js here is the official ESM
# single-file build (dist/echarts.esm.min.js), which has no further
# imports to resolve. See ADR 0005.
pin "echarts", to: "echarts.js"
