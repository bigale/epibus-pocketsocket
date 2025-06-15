import React, { useState } from 'react';
import { User } from 'lucide-react';

interface Character {
  id: string;
  name: string;
  expertise: string;
  personality: string;
  color: string;
  emoji: string;
}

const characters: Character[] = [
  {
    id: 'kyoko',
    name: 'Kyoko Kirigiri',
    expertise: 'Anomaly Detection & Investigation',
    personality: 'Analytical, methodical, mystery-solver',
    color: 'purple',
    emoji: '🔍'
  },
  {
    id: 'byakuya',
    name: 'Byakuya Togami',
    expertise: 'Process Optimization & Efficiency',
    personality: 'Strategic, efficient, perfectionist',
    color: 'blue',
    emoji: '📈'
  },
  {
    id: 'chihiro',
    name: 'Chihiro Fujisaki',
    expertise: 'System Analysis & Programming',
    personality: 'Technical, gentle, innovative',
    color: 'green',
    emoji: '💻'
  },
  {
    id: 'celestia',
    name: 'Celestia Ludenberg',
    expertise: 'Interface Design & Aesthetics',
    personality: 'Elegant, dramatic, perfectionist',
    color: 'red',
    emoji: '♠️'
  },
  {
    id: 'sakura',
    name: 'Sakura Ogami',
    expertise: 'Performance Monitoring & Strength',
    personality: 'Strong, reliable, disciplined',
    color: 'orange',
    emoji: '💪'
  }
];

interface CharacterSelectorProps {
  currentCharacter: string;
  onCharacterChange: (characterId: string) => void;
}

const CharacterSelector: React.FC<CharacterSelectorProps> = ({
  currentCharacter,
  onCharacterChange
}) => {
  const [isOpen, setIsOpen] = useState(false);

  // Debug logging
  console.log('CharacterSelector props:', { currentCharacter, onCharacterChange: typeof onCharacterChange });

  const getCurrentCharacterData = () => {
    return characters.find(c => c.id === currentCharacter) || characters[0];
  };

  const handleCharacterSelect = (characterId: string) => {
    console.log('Character selected:', characterId, 'onCharacterChange type:', typeof onCharacterChange);
    
    if (typeof onCharacterChange === 'function') {
      onCharacterChange(characterId);
      setIsOpen(false);
    } else {
      console.error('onCharacterChange is not a function! Received:', onCharacterChange);
      
      // Fallback: Try to directly open the character's dashboard
      const portMap: Record<string, number> = {
        'kyoko': 1881,
        'byakuya': 1882,
        'chihiro': 1883,
        'celestia': 1884,
        'sakura': 1885
      };
      
      const port = portMap[characterId];
      if (port) {
        const dashboardUrl = `http://localhost:${port}/api/ui`;
        console.log('Fallback: Opening dashboard:', dashboardUrl);
        
        window.open(dashboardUrl, `${characterId}-dashboard`, 'width=1200,height=800,scrollbars=yes,resizable=yes');
        setIsOpen(false);
      } else {
        alert(`Character selection error: Cannot switch to ${characterId}. Please refresh the page.`);
      }
    }
  };

  const currentChar = getCurrentCharacterData();

  const getColorClass = (color: string) => {
    const colorMap: Record<string, string> = {
      purple: 'bg-purple-500 hover:bg-purple-600',
      blue: 'bg-blue-500 hover:bg-blue-600',
      green: 'bg-green-500 hover:bg-green-600',
      red: 'bg-red-500 hover:bg-red-600',
      orange: 'bg-orange-500 hover:bg-orange-600'
    };
    return colorMap[color] || 'bg-gray-500 hover:bg-gray-600';
  };

  const getBorderClass = (color: string) => {
    const borderMap: Record<string, string> = {
      purple: 'border-purple-300',
      blue: 'border-blue-300',
      green: 'border-green-300',
      red: 'border-red-300',
      orange: 'border-orange-300'
    };
    return borderMap[color] || 'border-gray-300';
  };

  return (
    <div className="relative">
      {/* Current Character Button */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className={`flex items-center space-x-3 px-4 py-2 rounded-lg ${getColorClass(currentChar.color)} text-white transition-colors duration-200 min-w-[300px]`}
      >
        <span className="text-2xl">{currentChar.emoji}</span>
        <div className="text-left flex-1">
          <div className="font-semibold">{currentChar.name}</div>
          <div className="text-sm opacity-90">{currentChar.expertise}</div>
        </div>
        <User className="w-5 h-5" />
      </button>

      {/* Character Dropdown */}
      {isOpen && (
        <>
          {/* Backdrop */}
          <div 
            className="fixed inset-0 z-10" 
            onClick={() => setIsOpen(false)}
          />
          
          {/* Dropdown Menu */}
          <div className="absolute top-full left-0 mt-2 w-full bg-white rounded-lg shadow-xl border z-20 max-h-96 overflow-y-auto">
            {characters.map((character) => (
              <button
                key={character.id}
                onClick={() => handleCharacterSelect(character.id)}
                className={`w-full text-left px-4 py-3 hover:bg-gray-50 border-l-4 ${getBorderClass(character.color)} ${
                  character.id === currentCharacter ? 'bg-gray-50' : ''
                } transition-colors duration-150`}
              >
                <div className="flex items-center space-x-3">
                  <span className="text-2xl">{character.emoji}</span>
                  <div className="flex-1">
                    <div className="font-semibold text-gray-900">{character.name}</div>
                    <div className="text-sm text-gray-600">{character.expertise}</div>
                    <div className="text-xs text-gray-500 italic">{character.personality}</div>
                  </div>
                  {character.id === currentCharacter && (
                    <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                  )}
                </div>
              </button>
            ))}
          </div>
        </>
      )}
    </div>
  );
};

export default CharacterSelector;
