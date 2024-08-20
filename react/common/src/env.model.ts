// @ts-ignore
export const APP_TYPE: 'ADMIN' | 'USER' = import.meta.env.VITE_APP_TYPE;

export const APP_TYPE_KOR: string = APP_TYPE === 'ADMIN' ? '관리자' : '유저'