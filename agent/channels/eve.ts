import { eveChannel } from "eve/channels/eve";
import { httpBasic, localDev } from "eve/channels/auth";

/**
 * Self-hosted route auth: HTTP Basic in production, localDev for `eve`/`next` dev.
 * Set ROUTE_AUTH_BASIC_USERNAME / ROUTE_AUTH_BASIC_PASSWORD in the environment.
 * Do not use vercelOidc() outside Vercel.
 */
export default eveChannel({
  auth: [
    httpBasic(
      {
        username: process.env.ROUTE_AUTH_BASIC_USERNAME ?? "eve",
        password: process.env.ROUTE_AUTH_BASIC_PASSWORD ?? "",
      },
      { realm: "eve" },
    ),
    localDev(),
  ],
});
