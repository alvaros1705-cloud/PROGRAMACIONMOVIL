module.exports = function (api) {
  api.cache(true);
  return {
    presets: ['babel-preset-expo'],
    plugins: [
      [
        'module-resolver',
        {
          root: ['./'],
          alias: {
            '@medical-app/shared': './src',
            '@medical-app/shared/lib/supabase': './src/lib/supabase',
            '@medical-app/shared/hooks/useAuth': './src/hooks/useAuth',
            '@medical-app/shared/utils': './src/utils/index',
            '@medical-app/shared/types': './src/types/index',
          },
        },
      ],
    ],
  };
};
