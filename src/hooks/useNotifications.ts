
import { useEffect } from 'react';
import { FirebaseMessaging } from '@capacitor-firebase/messaging';
import { Capacitor } from '@capacitor/core';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from './useAuth';

export const useNotifications = () => {
    const { user } = useAuth();

    useEffect(() => {
        if (!user || Capacitor.getPlatform() === 'web') return;

        const initializeNotifications = async () => {
            try {
                // Request permissions
                const result = await FirebaseMessaging.requestPermissions();
                if (result.receive === 'granted') {
                    // Register for push notifications
                    await FirebaseMessaging.getToken().then(async (result) => {
                        const token = result.token;
                        console.log('FCM Token:', token);

                        // Save token to Supabase
                        const { error } = await (supabase as any)
                            .from('fcm_tokens')
                            .upsert(
                                {
                                    user_id: user.id,
                                    token: token,
                                    updated_at: new Date().toISOString()
                                },
                                { onConflict: 'token' }
                            );

                        if (error) console.error('Error saving FCM token:', error);
                    });
                }

                // Add listeners
                await FirebaseMessaging.addListener('notificationReceived', (event) => {
                    console.log('Notification received:', event);
                });

                await FirebaseMessaging.addListener('notificationActionPerformed', (event) => {
                    console.log('Notification action performed:', event);
                });

            } catch (error) {
                console.error('Error initializing notifications:', error);
            }
        };

        initializeNotifications();

        // Cleanup listeners
        return () => {
            FirebaseMessaging.removeAllListeners();
        };
    }, [user]);
};
