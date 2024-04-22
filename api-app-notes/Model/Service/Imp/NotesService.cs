using api_app_notes.Data;
using api_app_notes.Model.DTO;
using api_app_notes.Model.Entity;
using Microsoft.EntityFrameworkCore;
using System.Text;

namespace api_app_notes.Model.Service.Imp
{
    public class NotesService : INotesService
    {
        private readonly DataContext _context;
        public NotesService(DataContext dataContext)
        {
            _context = dataContext;
        }
        private async Task<bool> SaveChangesAsync()
        {
            try
            {
                int recordsAffected = await _context.SaveChangesAsync();
                return recordsAffected > 0;
            }
            catch (Exception ex)
            {
                Console.WriteLine("Lỗi khi lưu dữ liệu: " + ex.Message);
                return false;
            }
        }
        public async Task<IEnumerable<NotesDTO>> GetNotes(string email)
        {
            return await _context.Notes
                .Where(n => n.Email == email)
                .Select(n => new NotesDTO
                {
                    NoteId = n.NoteId,
                    Title = Encoding.UTF8.GetString(n.Title),
                    Content = Encoding.UTF8.GetString(n.Content),
                    Day = Encoding.UTF8.GetString(n.Day),
                    Time = Encoding.UTF8.GetString(n.Time),
                    Pass = Encoding.UTF8.GetString(n.Pass),
                    IsPinned = n.IsPinned,
                    Email = n.Email,
                })
                .ToListAsync();
        }

        public async Task<bool> AddNote(NotesDTO note)
        {
            var newNote = new Notes
            {
                Title = Encoding.UTF8.GetBytes(note.Title),
                Content = Encoding.UTF8.GetBytes(note.Content),
                Day = Encoding.UTF8.GetBytes(note.Day),
                Time = Encoding.UTF8.GetBytes(note.Time),
                Pass = Encoding.UTF8.GetBytes(note.Pass),
                IsPinned = note.IsPinned,
                Email = note.Email
            };

            await _context.Notes.AddAsync(newNote);
            return await SaveChangesAsync();
            
        }

        public async Task<bool> UpdateNote(NotesDTO note)
        {
            var existingNote = await _context.Notes.FindAsync(note.NoteId);

            if (existingNote == null)
                return false;

            existingNote.Title = Encoding.UTF8.GetBytes(note.Title);
            existingNote.Content = Encoding.UTF8.GetBytes(note.Content);
            existingNote.Day = Encoding.UTF8.GetBytes(note.Day);
            existingNote.Time = Encoding.UTF8.GetBytes(note.Time);
            existingNote.Pass = Encoding.UTF8.GetBytes(note.Pass);
            existingNote.IsPinned = note.IsPinned;

            try
            {
                _context.Notes.Update(existingNote);
                await _context.SaveChangesAsync();
                return true;
            }
            catch
            {
                return false;
            }
        }

        public async Task<bool> DeleteNote(int id)
        {
            var noteToDelete = await _context.Notes.FindAsync(id);

            if (noteToDelete == null)
                return false;

            try
            {
                _context.Notes.Remove(noteToDelete);
                await _context.SaveChangesAsync();
                return true;
            }
            catch
            {
                return false;
            }
        }
    }
}
