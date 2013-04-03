class GroupSummaryView extends KDCustomHTMLView

  constructor:(options = {}, data = {})->

    options.domId = "group-summary"

    super options, data

    @lazyDomController = @getSingleton("lazyDomController")

    @loader = new KDLoaderView
      size          :
        width       : 60
      loaderOptions :
        color       : "#ffffff"


    @sign = new KDCustomHTMLView
      tagName     : "div"
      cssClass    : "group-logo-wrapper"
      bind        : "mouseenter mouseleave"
      pistachio   : """
        <i></i><i></i>
        <h3 id="group-logo">{{#(title)}}</h3>
        """
      mouseenter  : -> @$().css marginTop : 13
      mouseleave  : -> @$().css marginTop : 8
      click       : @bound "showSummary"
    , {}

    @kodingLogo = new KDCustomHTMLView
      tagName     : "div"
      cssClass    : "summary-koding-logo"
      click       : @bound "showSummary"

    @landingPageLink = new CustomLinkView
      cssClass    : "public-page-link"
      title       : "Pull up the public page"
      icon        :
        placement : "right"
      click       : @bound "showLandingPage"

    @openInKodingLink = new CustomLinkView
      cssClass    : "open-in-koding"
      title       : "Open the group in Koding"
      icon        : {}
      click       : @bound "hideLandingPage"

    @closeLink = new CustomLinkView
      cssClass    : "close-link"
      title       : ""
      icon        :
        placement : "right"
      click       : (event)=>
        event.stopPropagation()
        event.preventDefault()
        @unsetClass "shown"
        @utils.wait 400, =>
          @sign.setClass "swing-in"

    @once "viewAppended", @loader.bound "show"
    @once "viewAppended", @bound "decorateSummary"

  viewAppended: JView::viewAppended

  pistachio:->
    """
      {{> @kodingLogo}}
      {{> @loader}}
      <header>
        <div class='avatar-wrapper'></div>
        <div class='right-overflow'></div>
      </header>
      <aside></aside>
      {{> @landingPageLink}}
      {{> @closeLink}}
      {{> @openInKodingLink}}
      {{> @sign}}
    """

  showSummary:(event)->
    if event
      event.stopPropagation()
      event.preventDefault()
    @sign.setClass "swing-out"
    @sign.unsetClass "swing-in"
    @utils.wait 400, =>
      @sign.unsetClass "swing-out"
      @setClass "shown"

  hideSummary:(event)->
    if event
      event.stopPropagation()
      event.preventDefault()
    @unsetClass "shown"
    @utils.wait 400, =>
      @sign.unsetClass "swing-out"
      @sign.unsetClass "swing-in"
      @$().css
        top    : ""
        bottom : ""

  decorateSummary:->

    KD.remote.cacheable KD.config.groupEntryPoint, (err, models)=>
      if err then callback err
      else if models?
        [group] = models
        @sign.setData group
        @sign.render()

        group.fetchAdmin (err, owner)=>
          if err then warn err
          else
            @loader.hide()
            @putOwner owner
            @putGroupBio group
            @positionSummary()

        group.fetchMembers (err, members)=>
          if err then warn err
          else if members.length
            @putList members

  putOwner:(owner)->

    ownerAvatar = new AvatarView
      cssClass  : "owner"
      size      :
        width   : 60
        height  : 60
    , owner

    @addSubView ownerAvatar, '.avatar-wrapper'

    title = new KDHeaderView
      type  : "medium"
      title : "#{@utils.getFullnameFromAccount owner} created this group."

    @addSubView title, '.right-overflow'

  putGroupBio:(group)->

    bio = new KDCustomHTMLView
      tagName   : "p"
      cssClass  : "bio"
      partial   : group.body or "This is a group created within Koding, group admins decide wether to share members/activities/topics of this group. Unless it is wanted Koding members won't be able to see the content shared in this group."

    @addSubView bio, '.right-overflow'

  putList:(members)->
    log members
    controller = new KDListViewController
      view         : @members = new KDListView
        wrapper    : no
        scrollView : no
        type       : "members"
        itemClass  : GroupItemMemberView

    @addSubView @members, 'aside'
    controller.instantiateListItems members

  positionSummary:->
    if @lazyDomController.isLandingPageVisible()
      @$().css
        top    : ""
        bottom : -@getHeight()
    else
      @$().css
        top    : -@getHeight()
        bottom : ""

  showLandingPage:(event)->

    event.stopPropagation()
    event.preventDefault()
    @hideSummary()
    @utils.wait 300, =>
      @hide()
      @lazyDomController.showLandingPage =>
        @show()
        @positionSummary()

  hideLandingPage:(event)->

    event.stopPropagation()
    event.preventDefault()
    @hideSummary()
    @utils.wait 300, =>
      @hide()
      @lazyDomController.hideLandingPage =>
        @show()
        @positionSummary()
