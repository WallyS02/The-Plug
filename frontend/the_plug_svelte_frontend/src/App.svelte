<script lang="ts">
  import Router from "svelte-spa-router";
  import Home from "./routes/Home.svelte";
  import NotFound from "./routes/NotFound.svelte";
  import AccountPanel from "./routes/AccountPanel.svelte";
  import Register from "./routes/Register.svelte";
  import Login from "./routes/Login.svelte";
  import RequestMeeting from "./routes/RequestMeeting.svelte";
  import PlugPanel from "./routes/PlugPanel.svelte";
  import Navbar from "./lib/Navbar.svelte";
  import Footer from "./lib/Footer.svelte";
  import MeetingPanel from "./routes/MeetingPanel.svelte";
  import HerbEdit from "./routes/HerbOfferEdit.svelte";
  import LocationEdit from "./routes/LocationEdit.svelte";
  import RequestNewHerb from "./routes/RequestNewHerb.svelte";
  import RatingInfo from "./routes/RatingInfo.svelte";
  import Locations from "./routes/Locations.svelte";
  import HerbOffers from "./routes/HerbOffers.svelte";
  import Meetings from "./routes/Meetings.svelte";
  import PlugMeetings from "./routes/PlugMeetings.svelte";

  const routes = {
    '/': Home,
    '/register': Register,
    '/login': Login,
    '/new-herb': RequestNewHerb,
    '/rating-info': RatingInfo,
    '/account/:id': AccountPanel,
    '/plug/:id': PlugPanel,
    '/herb-offer/:id': HerbEdit,
    '/location/:id': LocationEdit,
    '/locations/:id': Locations,
    '/herb-offers/:id': HerbOffers,
    '/plug-meetings/:id': PlugMeetings,
    '/meetings/:id': Meetings,
    '/meeting/:id': MeetingPanel,
    '/request-meeting/:id': RequestMeeting,
    '*': NotFound,
  }
</script>

<style>
  @import 'tailwindcss/tailwind.css';
</style>

<main class="p-4">
  <Navbar/>
  <Router {routes} />
  <Footer/>
</main>
