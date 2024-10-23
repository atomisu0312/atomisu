/**
 * @type {import('next').NextConfig}
 */
const nextConfig = {
  images: {
    unoptimized: true,
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'images.ygoprodeck.com',
        pathname: '/images/**',
      },
    ],
  },
  serverRuntimeConfig: {
    myPort: process.env.PORT || 3000, // 環境変数PORTが設定されていない場合は3000を使用
  },
  env: {
    NEXTAUTH_URL: process.env.NEXTAUTH_URL,
    GOOGLE_CLIENT_ID: process.env.GOOGLE_CLIENT_ID,
    GOOGLE_CLIENT_SECRET: process.env.GOOGLE_CLIENT_SECRET,
    AUTH_SECRET: process.env.AUTH_SECRET,
    AUTH_TRUST_HOST: process.env.AUTH_TRUST_HOST,
    FASTAPI_ACCOUNT_SERVICE_HOST: process.env.FASTAPI_ACCOUNT_SERVICE_HOST,
  },
  output: 'standalone',
  webpack: (config, { isServer }) => {
    if (!isServer) {
      config.resolve.fallback = {
        fs: false,
        dns: false,
        net: false,
        tls: false,
      };
    }
    return config;
  },
}

module.exports = nextConfig