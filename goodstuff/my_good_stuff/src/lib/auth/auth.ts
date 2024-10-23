import NextAuth from "next-auth";
import GoogleProvider from "next-auth/providers/google";

export const { handlers, auth, signIn, signOut } = NextAuth({
  providers: [
    GoogleProvider({
      clientId: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    }),
  ],
  callbacks: {
    authorized({ request, auth }) {
      const { pathname } = request.nextUrl;
      if (pathname === "/global") {
        return true;
      }
      return !!auth;
    },
    async redirect({ url, baseUrl }) {
      // Allows relative callback URLs
      //if (url.startsWith("/")) return `${baseUrl}${url}`

      // Allows callback URLs on the same origin
      //if(new URL(url).origin === baseUrl) return url
      return baseUrl
    }
  },
});
