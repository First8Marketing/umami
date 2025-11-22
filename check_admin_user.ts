import { PrismaClient } from './src/generated/prisma/client';

const prisma = new PrismaClient();

async function main() {
  try {
    await prisma.user.findUnique({
      where: { username: 'admin' },
      select: {
        id: true,
        username: true,
        password: true,
        role: true,
        createdAt: true,
        deletedAt: true,
      },
    });
    // console.log('Admin user:', user);
  } catch {
    // console.error('Error querying admin user:', err);
  } finally {
    await prisma.$disconnect();
  }
}

main();
