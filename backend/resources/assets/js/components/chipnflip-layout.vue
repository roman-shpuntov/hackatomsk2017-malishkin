<template lang="pug">
  .chipnflip-layout
    header
      .container
        a.homepage-link(href="#/"): img(src="/images/home.png" alt="home")
        .tabs
          .tab: a(href="#/credits") 150 credits
          .tab: a(href="#/howtoplay") How to play
          .tab: a(href="#/settings") Settings
          .tab: a(href="#/logout") Log out&nbsp;&nbsp;#[img(src="/images/log-out.png")]
    slot
    footer
      .container.fullheight
        .brand Chip'n'Flip
        .links
          a(href="#/credits") Credits
          a(href="#/howtoplay") How to play
          a(href="#/settings") Settings
          a(href="#/terms") Terms and conditions
        .social-icons
          .social-icon: img(src="/images/social/vk.png")
          .social-icon: img(src="/images/social/f.png")
          .social-icon: img(src="/images/social/ok.png")
          .social-icon: img(src="/images/social/g+.png")
          .social-icon: img(src="/images/social/twitter.png")
        .phone +7 (800) 888-98-88
</template>

<script>
export default {
  props: ["dickBig"]
}
</script>
