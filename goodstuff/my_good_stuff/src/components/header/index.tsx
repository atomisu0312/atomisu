import { auth, signIn, signOut } from '@/lib/auth/auth';
import { Session } from "next-auth";


export default async function header() {
  const session: Session | null = await auth();

  return (
    <>
      <div className="px-2 grid grid-cols-12 py-7">
        <div className="col-span-1"></div>
        <div className="col-span-10 flex justify-center items-center">
          {session ? <div>user: {session.user?.name || "Guest"}</div> : <div>user: not signed in</div>}
        </div>
        <div className="col-span-1">
          <form
            action={async () => {
              'use server';
              await signOut();
            }}>
            <button className="flex h-[48px] w-full grow items-center justify-center gap-2 rounded-md bg-gray-50 p-3 text-sm font-medium hover:bg-sky-100 hover:text-blue-600 md:flex-none md:justify-start md:p-2 md:px-3">

              <div className="hidden md:block">Sign Out</div>
            </button>
          </form>
        </div>
      </div>
    </>
  )
}