export function TundukLogo({ size = 80 }: { size?: number }) {
  return (
    <svg 
      width={size} 
      height={size} 
      viewBox="0 0 100 100" 
      fill="none" 
      xmlns="http://www.w3.org/2000/svg"
    >
      {/* Outer circle - Sky Blue */}
      <circle cx="50" cy="50" r="48" fill="#2F80ED" opacity="0.1" />
      
      {/* Tunduk structure - simplified yurt roof view */}
      <circle cx="50" cy="50" r="35" stroke="#2F80ED" strokeWidth="3" fill="none" />
      
      {/* Center circle */}
      <circle cx="50" cy="50" r="8" fill="#F2C94C" />
      
      {/* Radiating lines (8 directions) */}
      <g stroke="#2F80ED" strokeWidth="2.5" strokeLinecap="round">
        {/* Top */}
        <line x1="50" y1="15" x2="50" y2="35" />
        {/* Top Right */}
        <line x1="74.75" y1="25.25" x2="60.6" y2="39.4" />
        {/* Right */}
        <line x1="85" y1="50" x2="65" y2="50" />
        {/* Bottom Right */}
        <line x1="74.75" y1="74.75" x2="60.6" y2="60.6" />
        {/* Bottom */}
        <line x1="50" y1="85" x2="50" y2="65" />
        {/* Bottom Left */}
        <line x1="25.25" y1="74.75" x2="39.4" y2="60.6" />
        {/* Left */}
        <line x1="15" y1="50" x2="35" y2="50" />
        {/* Top Left */}
        <line x1="25.25" y1="25.25" x2="39.4" y2="39.4" />
      </g>
      
      {/* Decorative inner ring */}
      <circle cx="50" cy="50" r="20" stroke="#2F80ED" strokeWidth="1.5" fill="none" opacity="0.3" />
    </svg>
  );
}
