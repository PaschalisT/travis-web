Travis.RepoController = Ember.Controller.extend
  needs: ['repos', 'currentUser', 'build', 'request', 'job']
  currentUserBinding: 'controllers.currentUser'

  build: Ember.computed.alias('controllers.build.build')
  job: Ember.computed.alias('controllers.job.job')
  request: Ember.computed.alias('controllers.request.model')

  slug: (-> @get('repo.slug') ).property('repo.slug')
  isLoading: (-> @get('repo.isLoading') ).property('repo.isLoading')

  init: ->
    @_super.apply this, arguments
    if !Ember.testing
      Visibility.every Travis.INTERVALS.updateTimes, @updateTimes.bind(this)

  updateTimes: ->
    Ember.run this, ->
      if builds = @get('builds')
        builds.forEach (b) -> b.updateTimes()

      if build = @get('build')
        build.updateTimes()

      if build && jobs = build.get('jobs')
        jobs.forEach (j) -> j.updateTimes()

  deactivate: ->
    @stopObservingLastBuild()

  activate: (action) ->
    @stopObservingLastBuild()
    this["view#{$.camelize(action)}"]()

  viewIndex: ->
    @observeLastBuild()
    @connectTab('current')

  viewCurrent: ->
    @observeLastBuild()
    @connectTab('current')

  viewBuilds: ->
    @connectTab('builds')

  viewPullRequests: ->
    @connectTab('pull_requests')

  viewBranches: ->
    @connectTab('branches')

  viewBuild: ->
    @connectTab('build')

  viewJob: ->
    @connectTab('job')

  viewRequests: ->
    @connectTab('requests')

  viewCaches: ->
    @connectTab('caches')

  viewRequest: ->
    @connectTab('request')

  viewSettings: ->
    @connectTab('settings')

  lastBuildDidChange: ->
    Ember.run.scheduleOnce('data', this, @_lastBuildDidChange);

  _lastBuildDidChange: ->
    build = @get('repo.lastBuild')
    @set('build', build)

  stopObservingLastBuild: ->
    @removeObserver('repo.lastBuild', this, 'lastBuildDidChange')

  observeLastBuild: ->
    @lastBuildDidChange()
    @addObserver('repo.lastBuild', this, 'lastBuildDidChange')

  connectTab: (tab) ->
    # TODO: such implementation seems weird now, because we render
    #       in the renderTemplate function in routes
    name = if tab == 'current' then 'build' else tab
    @set('tab', tab)

  urlGithub: (->
    Travis.Urls.githubRepo(@get('repo.slug'))
  ).property('repo.slug')
