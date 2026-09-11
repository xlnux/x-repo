import type { Metadata } from "next";
import { Anonymous_Pro } from "next/font/google";
import "./globals.css";

const anonymous = Anonymous_Pro({
  weight: ['400', '700'],
  subsets: ['latin'],
  variable: '--font-anonymous',
  display: 'swap',
});

export const metadata: Metadata = {
  title: "x-repo · X Linux",
  description: "Dedicated repository for serving artifacts for X Linux.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={`${anonymous.variable} antialiased`}>{children}</body>
    </html>
  );
}
