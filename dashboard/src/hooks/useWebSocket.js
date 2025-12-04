import { useState, useEffect, useRef } from 'react';

export const useWebSocket = (url, token, onMessage) => {
    const ws = useRef(null);

    useEffect(() => {
        if (!token) return;

        // Backend expects token in query param: /ws/bin-status?token=...
        const socketUrl = `${url}?token=${token}`;
        ws.current = new WebSocket(socketUrl);

        ws.current.onopen = () => console.log(`Connected to ${url}`);

        ws.current.onmessage = (event) => {
            const data = JSON.parse(event.data);
            if (onMessage) onMessage(data);
        };

        ws.current.onclose = () => console.log(`Disconnected from ${url}`);

        return () => {
            if (ws.current) ws.current.close();
        };
    }, [url, token, onMessage]);
};